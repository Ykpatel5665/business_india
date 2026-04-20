// One-shot downloader for the Kenney.nl boardgame-pack ZIP. Not part of the
// app build — run with `dart run tool/fetch_kenney.dart`. Fail fast, fall
// back to painters if nothing downloads.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;

const List<String> candidateUrls = [
  'https://kenney.nl/media/pages/assets/boardgame-pack/ee9b70da74-1740057481/kenney_boardgame-pack.zip',
  'https://kenney.nl/media/pages/assets/boardgame-pack/kenney_boardgame-pack.zip',
];

const String targetRoot = 'assets/images';

String classify(String filename) {
  final f = filename.toLowerCase();
  if (f.contains('dice') || f.contains('token') || f.contains('piece') ||
      f.contains('pawn') || f.contains('meeple')) {
    return 'tokens';
  }
  if (f.contains('card')) return 'cards';
  if (f.contains('board') || f.contains('tile') || f.contains('square')) {
    return 'tiles';
  }
  if (f.contains('wood') || f.contains('felt') || f.contains('background') ||
      f.contains('bg') || f.contains('table') || f.contains('paper')) {
    return 'backgrounds';
  }
  if (f.contains('button') || f.contains('icon') || f.contains('panel') ||
      f.contains('ui')) {
    return 'ui';
  }
  return 'ui';
}

Future<List<int>?> tryDownload(String url) async {
  try {
    stdout.writeln('Trying $url');
    final res = await http.get(Uri.parse(url)).timeout(
          const Duration(seconds: 60),
        );
    if (res.statusCode != 200) {
      stdout.writeln('  status ${res.statusCode}');
      return null;
    }
    if (res.bodyBytes.length < 1024) {
      stdout.writeln('  body too small (${res.bodyBytes.length} bytes)');
      return null;
    }
    stdout.writeln('  ok, ${res.bodyBytes.length} bytes');
    return res.bodyBytes;
  } catch (e) {
    stdout.writeln('  error: $e');
    return null;
  }
}

Future<void> main() async {
  List<int>? zipBytes;
  String? successUrl;
  for (final url in candidateUrls) {
    final bytes = await tryDownload(url);
    if (bytes != null) {
      zipBytes = bytes;
      successUrl = url;
      break;
    }
  }

  if (zipBytes == null) {
    stdout.writeln('Kenney download failed — falling back to painters.');
    exitCode = 1;
    return;
  }

  final archive = ZipDecoder().decodeBytes(zipBytes);
  final manifest = <String, List<String>>{
    'tiles': [],
    'tokens': [],
    'cards': [],
    'ui': [],
    'backgrounds': [],
  };

  for (final entry in archive) {
    if (!entry.isFile) continue;
    final name = entry.name;
    final lower = name.toLowerCase();
    if (!(lower.endsWith('.png') || lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg'))) {
      continue;
    }
    final bucket = classify(name.split('/').last);
    final outName = name.split('/').last;
    final outPath = '$targetRoot/$bucket/$outName';
    final outFile = File(outPath);
    await outFile.parent.create(recursive: true);
    await outFile.writeAsBytes(entry.content as List<int>);
    manifest[bucket]!.add(outName);
  }

  final manifestFile = File('$targetRoot/asset_manifest.json');
  await manifestFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert({
      'source': successUrl,
      'counts': {for (final e in manifest.entries) e.key: e.value.length},
      'files': manifest,
    }),
  );

  final total = manifest.values.fold<int>(0, (a, b) => a + b.length);
  stdout.writeln('Extracted $total files. Manifest at ${manifestFile.path}');
}
