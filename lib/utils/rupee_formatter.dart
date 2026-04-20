import 'package:intl/intl.dart';

/// Formats an integer rupee amount using the Indian numbering system
/// (lakh / crore grouping).
///
/// Examples:
///   1500      -> ₹1,500
///   1500000   -> ₹15,00,000
///   12345678  -> ₹1,23,45,678
///
/// Pass `symbol: ''` to omit the ₹ prefix (e.g. for inline labels).
class RupeeFormatter {
  RupeeFormatter._();

  static final NumberFormat _indianFormat =
      NumberFormat.decimalPattern('en_IN');

  static String format(int amount, {String symbol = '₹'}) {
    final formatted = _indianFormat.format(amount);
    return symbol.isEmpty ? formatted : '$symbol$formatted';
  }

  /// Compact form for tight UI:
  ///   1500     -> ₹1,500
  ///   150000   -> ₹1.5L
  ///   12500000 -> ₹1.25Cr
  static String compact(int amount, {String symbol = '₹'}) {
    final prefix = symbol.isEmpty ? '' : symbol;
    final abs = amount.abs();
    String body;
    if (abs >= 10000000) {
      body = '${_trim(amount / 10000000)}Cr';
    } else if (abs >= 100000) {
      body = '${_trim(amount / 100000)}L';
    } else if (abs >= 1000) {
      body = '${_trim(amount / 1000)}K';
    } else {
      body = amount.toString();
    }
    return '$prefix$body';
  }

  /// Formats a double with up to 2 decimals, stripping trailing zeros
  /// (1.5 → "1.5", 1.25 → "1.25", 2.0 → "2").
  static String _trim(double value) {
    var s = value.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }
}
