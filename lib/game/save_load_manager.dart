import 'package:hive/hive.dart';
import '../game_logic/engine/game_engine.dart';
import '../game_logic/persistence/hive_persistence.dart';

class SaveLoadManager {
  final HivePersistence _hivePersistence = HivePersistence();

  Future<void> saveGame(GameEngine engine) async {
    await _hivePersistence.saveGameState(engine);
  }

  Future<void> loadGame(GameEngine engine) async {
    await _hivePersistence.loadGameState(engine);
  }

  // Optionally, add a method to clear the save
  Future<void> clearSave() async {
    final box = await Hive.openBox(HivePersistence.gameStateBoxName);
    await box.clear();
  }

  Future<bool> hasSave() async {
    final box = await Hive.openBox(HivePersistence.gameStateBoxName);
    return box.isNotEmpty;
  }
}
