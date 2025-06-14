import 'package:flutter/material.dart';
import 'game_log_manager.dart';
import 'responsive_utils.dart';

class GameLogOverlay extends StatelessWidget {
  final GameLogManager logManager;
  final VoidCallback onClose;
  const GameLogOverlay({Key? key, required this.logManager, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 250),
          child: Semantics(
            label: 'Game Log Overlay',
            explicitChildNodes: true,
            child: Material(
              color: Colors.black54,
              child: Container(
                width: ResponsiveUtils.dialogWidth(context),
                height: ResponsiveUtils.dialogHeight(context),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Game Log', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Semantics(
                          label: 'Close game log overlay',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: logManager,
                        builder: (context, _) {
                          final entries = logManager.logEntries;
                          if (entries.isEmpty) {
                            return const Center(child: Text('No events yet.'));
                          }
                          return ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(entries[i]),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Semantics(
                        label: 'Clear game log',
                        button: true,
                        child: TextButton(
                          onPressed: logManager.clear,
                          child: const Text('Clear Log'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
