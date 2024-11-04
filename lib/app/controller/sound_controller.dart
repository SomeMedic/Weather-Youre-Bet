import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SoundController extends GetxController {
  final Map<String, AudioPlayer> players = {};
  final Map<String, double> volumes = {};
  final Map<String, bool> isPlaying = {};
  Timer? sleepTimer;
  final RxInt remainingMinutes = 0.obs;

  void initPlayer(String soundPath) {
    if (!players.containsKey(soundPath)) {
      players[soundPath] = AudioPlayer();
      volumes[soundPath] = 1.0;
      isPlaying[soundPath] = false;
    }
  }

  Future<void> togglePlay(String soundPath) async {
    initPlayer(soundPath);
    
    if (isPlaying[soundPath]!) {
      await players[soundPath]!.stop();
      isPlaying[soundPath] = false;
    } else {
      await players[soundPath]!.play(AssetSource(soundPath));
      await players[soundPath]!.setVolume(volumes[soundPath]!);
      players[soundPath]!.setReleaseMode(ReleaseMode.loop);
      isPlaying[soundPath] = true;
    }
    update();
  }

  Future<void> updateVolume(String soundPath, double volume) async {
    volumes[soundPath] = volume;
    if (isPlaying[soundPath]!) {
      await players[soundPath]!.setVolume(volume);
    }
    update();
  }

  void startSleepTimer(int minutes) {
    cancelSleepTimer();
    remainingMinutes.value = minutes;
    sleepTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      remainingMinutes.value--;
      if (remainingMinutes.value <= 0) {
        stopAllSounds();
        cancelSleepTimer();
      }
    });
    update();
  }

  void cancelSleepTimer() {
    sleepTimer?.cancel();
    remainingMinutes.value = 0;
    update();
  }

  void stopAllSounds() {
    for (var entry in players.entries) {
      players[entry.key]!.stop();
      isPlaying[entry.key] = false;
    }
    update();
  }

  @override
  void onClose() {
    for (var player in players.values) {
      player.dispose();
    }
    super.onClose();
  }
}
