import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum Sound { move, blocked, doorOpen, doorClose, loop, undo, win }

const Map<Sound, String> _assets = <Sound, String>{
  Sound.move: 'sfx/move.wav',
  Sound.blocked: 'sfx/blocked.wav',
  Sound.doorOpen: 'sfx/door_open.wav',
  Sound.doorClose: 'sfx/door_close.wav',
  Sound.loop: 'sfx/loop.wav',
  Sound.undo: 'sfx/undo.wav',
  Sound.win: 'sfx/win.wav',
};

/// Kisa ses efektleri.
///
/// Kucuk bir oynatici havuzu kullanir; ust uste binen sesler (hamle + kapi)
/// birbirini kesmez. Ses altyapisi calismazsa oyun sessiz devam eder, asla
/// hata firlatmaz.
class Sfx {
  static const int _poolSize = 4;

  final List<AudioPlayer> _pool = <AudioPlayer>[];
  int _next = 0;
  bool _ready = false;
  bool enabled = true;

  Future<void> init({required bool enabled}) async {
    this.enabled = enabled;
    try {
      // Kisa efektler ses odagi ISTEMEZ. Aksi halde her hamlede oyuncunun
      // arka planda calan muzigi kisilir ve havuzdaki sesler birbirini keser.
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
      for (var i = 0; i < _poolSize; i++) {
        final player = AudioPlayer(playerId: 'sfx$i');
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(0.6);
        _pool.add(player);
      }
      _ready = true;
    } on Object catch (error) {
      debugPrint('Ses altyapisi baslatilamadi, sessiz devam ediliyor: $error');
      _ready = false;
    }
  }

  void play(Sound sound) {
    if (!enabled || !_ready) {
      return;
    }
    final player = _pool[_next];
    _next = (_next + 1) % _pool.length;
    unawaited(
      player.play(AssetSource(_assets[sound]!)).catchError((Object _) {}),
    );
  }

  Future<void> dispose() async {
    for (final player in _pool) {
      await player.dispose();
    }
    _pool.clear();
    _ready = false;
  }
}

/// Oyun boyunca tek ornek; ekranlar arasinda tasimak yerine dogrudan kullanilir.
final Sfx sfx = Sfx();
