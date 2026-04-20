import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

class EntryDetailViewModel extends ChangeNotifier {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _playerReady = false;
  bool get playerReady => _playerReady;

  int? _playingIndex;
  int? get playingIndex => _playingIndex;

  bool _transitioning = false;
  bool get transitioning => _transitioning;

  Future<void> initPlayer() async {
    await _player.openPlayer();
    _player.setSubscriptionDuration(const Duration(milliseconds: 100));
    _playerReady = true;
    notifyListeners();
  }

  Future<void> togglePlayback(int index, List<String> audioPaths) async {
    if (!_playerReady || _transitioning) return;

    final path = audioPaths[index];
    final exists = await File(path).exists();
    debugPrint('Audio path: $path — exists: $exists');

    if (!exists) return;
    _transitioning = true;
    notifyListeners();

    try {
      if (_playingIndex == index) {
        await _player.stopPlayer();
        _playingIndex = null;
        return;
      }

      if (_player.isPlaying) await _player.stopPlayer();

      await _player.startPlayer(
        fromURI: audioPaths[index],
        codec: Codec.aacADTS,
        whenFinished: () {
          _playingIndex = null;
          notifyListeners();
        },
      );

      _playingIndex = index;
    } catch (e) {
      _playingIndex = null;
    } finally {
      _transitioning = false;
      notifyListeners();
    }
  }

  Future<void> stopPlayback() async {
    if (_player.isPlaying) await _player.stopPlayer();
    _playingIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }
}
