import 'package:flutter/material.dart';
import 'network_manager.dart';

class MultiplayerOverlay extends StatefulWidget {
  final VoidCallback onHost;
  final void Function(String gameId) onJoin;
  final VoidCallback onClose;
  const MultiplayerOverlay({Key? key, required this.onHost, required this.onJoin, required this.onClose}) : super(key: key);

  @override
  State<MultiplayerOverlay> createState() => _MultiplayerOverlayState();
}

class _MultiplayerOverlayState extends State<MultiplayerOverlay> {
  final controller = TextEditingController();
  bool isReady = false;

  @override
  Widget build(BuildContext context) {
    final network = NetworkManager();
    return Center(
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 250),
          child: Material(
            color: Colors.black54,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Online Multiplayer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onHost,
                    child: const Text('Host Game'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Game ID to Join'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => widget.onJoin(controller.text),
                    child: const Text('Join Game'),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Text('Players', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...network.players.map((p) => ListTile(
                    leading: Icon(p.isHost ? Icons.star : Icons.person),
                    title: Text(p.name),
                    subtitle: Text(p.isReady ? 'Ready' : 'Not Ready'),
                    trailing: p.id == network.myId
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isReady = !isReady;
                                network.setReady(p.id, isReady);
                              });
                            },
                            child: Text(isReady ? 'Unready' : 'Ready'),
                          )
                        : null,
                  )),
                  const SizedBox(height: 12),
                  if (network.isHost && network.allReady())
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Broadcast game start
                      },
                      child: const Text('Start Game'),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: widget.onClose,
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
