import 'package:flame_audio/flame_audio.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  Future<void> playDiceRoll() async {
    // await FlameAudio.play('dice_roll.mp3');
  }

  Future<void> playPurchase() async {
    // await FlameAudio.play('purchase.mp3');
  }

  Future<void> playRent() async {
    // await FlameAudio.play('rent.mp3');
  }

  Future<void> playBankrupt() async {
    // await FlameAudio.play('bankrupt.mp3');
  }

  Future<void> playWin() async {
    // await FlameAudio.play('win.mp3');
  }

  Future<void> playButton() async {
    // await FlameAudio.play('button.mp3');
  }

  Future<void> playBackgroundMusic() async {
    // await FlameAudio.bgm.play('assets/background_music.mp3', volume: 0.3);
  }

  Future<void> stopBackgroundMusic() async {
    // await FlameAudio.bgm.stop();
  }
}
