import 'package:flutter/material.dart';

class ChatOverlay extends StatefulWidget {
  final List<String> messages;
  final void Function(String) onSend;
  final VoidCallback onClose;
  const ChatOverlay({required this.messages, required this.onSend, required this.onClose, Key? key}) : super(key: key);

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 250),
          child: Card(
            elevation: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView(
                    shrinkWrap: true,
                    children: widget.messages.map((msg) => ListTile(title: Text(msg))).toList(),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            widget.onSend(val.trim());
                            _controller.clear();
                          }
                        },
                        decoration: const InputDecoration(hintText: 'Type a message...'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final val = _controller.text.trim();
                        if (val.isNotEmpty) {
                          widget.onSend(val);
                          _controller.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
