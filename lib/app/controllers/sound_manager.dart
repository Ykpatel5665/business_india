import 'package:flutter/foundation.dart';

/// Sound effects stub. Audio files are not yet shipped — every method is a
/// no-op except for an optional debug log. When assets land, wire
/// `audioplayers` behind each method.
enum GameSound {
  buttonTap,
  diceRoll,
  diceLand,
  tokenStep,
  passGo,
  buyProperty,
  rentPaid,
  cardFlip,
  auctionBid,
  buildHouse,
  mortgage,
  jail,
  bankrupt,
  win,
}

class SoundManager {
  SoundManager._();
  static final SoundManager instance = SoundManager._();

  bool sfxEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  void play(GameSound sound) {
    if (!sfxEnabled) return;
    if (kDebugMode) {
      // debugPrint('[sound] ${sound.name}');
    }
    // TODO(audio): wire audioplayers once SFX assets ship.
  }

  void playMusic() {
    if (!musicEnabled) return;
    // TODO(audio): background track loop.
  }

  void stopMusic() {
    // TODO(audio): stop loop.
  }

  // Convenience wrappers for common call sites.
  void tap() => play(GameSound.buttonTap);
  void dice() => play(GameSound.diceRoll);
  void rent() => play(GameSound.rentPaid);
  void win() => play(GameSound.win);
}
