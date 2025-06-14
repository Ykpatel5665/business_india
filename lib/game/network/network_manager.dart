import 'dart:async';

/// Represents a player in the networked game.
class NetworkPlayer {
  final String id;
  final String name;
  bool isHost;
  bool isReady;

  NetworkPlayer({
    required this.id,
    required this.name,
    this.isHost = false,
    this.isReady = false,
  });
}

/// Abstracts multiplayer networking for Monopoly.
class NetworkManager {
  // Singleton pattern
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  // Callbacks for game state sync
  void Function(Map<String, dynamic> state)? onStateReceived;
  void Function(String event, dynamic data)? onEventReceived;

  // Simulated connection state
  bool connected = false;

  // Player management
  List<NetworkPlayer> players = [];
  String? myId;
  bool isHost = false;

  Future<void> connectToServer(String gameId) async {
    // TODO: Implement real WebSocket or REST connection
    connected = true;
    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> hostGame() async {
    // TODO: Implement real host logic
    connected = true;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> sendState(Map<String, dynamic> state) async {
    // TODO: Send state to server/peers
  }

  Future<void> sendEvent(String event, dynamic data) async {
    // TODO: Send event to server/peers
  }

  Future<void> disconnect() async {
    connected = false;
  }

  // Simulated: add/remove players, set ready, broadcast events
  void addPlayer(String id, String name, {bool host = false}) {
    players.add(NetworkPlayer(id: id, name: name, isHost: host));
    if (host) isHost = true;
  }

  void setReady(String id, bool ready) {
    final p = players.firstWhere(
        (p) => p.id == id,
        orElse: () => NetworkPlayer(id: id, name: 'Unknown'));
    p.isReady = ready;
    // TODO: Broadcast ready state
  }

  void removePlayer(String id) {
    players.removeWhere((p) => p.id == id);
  }

  bool allReady() => players.isNotEmpty && players.every((p) => p.isReady);

  // Reconnection logic
  Future<void> reconnect(String myId) async {
    // Simulate reconnection
    connected = true;
    this.myId = myId;
    // Optionally re-fetch player list/state from server
    // TODO: Implement real reconnection logic
  }

  // Host migration logic
  void handleHostLeft() {
    // Elect new host: first non-host player in the list
    final nonHostPlayers = players.where((p) => !p.isHost).toList();
    if (nonHostPlayers.isNotEmpty) {
      final newHost = nonHostPlayers.first;
      newHost.isHost = true;
      isHost = newHost.id == myId;
      // Optionally broadcast new host event
      sendEvent('host_migrated', newHost.id);
    }
  }

  // Call this when a player leaves
  void playerLeft(String id) {
    final wasHost = players.firstWhere((p) => p.id == id, orElse: () => NetworkPlayer(id: id, name: 'Unknown')).isHost;
    removePlayer(id);
    if (wasHost) {
      handleHostLeft();
    }
  }
}
