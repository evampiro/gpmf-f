import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final spaceIntentProvider = StateProvider<Function>((ref) {
  return () {};
});

int map(int x, int in_min, int in_max, int out_min, int out_max) {
  var calc = ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)
      .toInt();
  if (calc > out_max) {
    return out_max;
  } else if (calc < out_min) {
    return out_min;
  } else {
    return calc;
  }
}

double mapDouble(
    {required double x,
    required double in_min,
    required double in_max,
    required double out_min,
    required double out_max}) {
  var calc = ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
  if (calc > out_max) {
    return out_max;
  } else if (calc < out_min) {
    return out_min;
  } else {
    return calc;
  }
}

Directory getAssetDirectory() {
  // returns the abolute path of the executable file of your app:
  String mainPath = Platform.resolvedExecutable;

// remove from that path the name of the executable file of your app:
  mainPath = mainPath.substring(0, mainPath.lastIndexOf("\\"));

// concat the path with '\data\flutter_assets\assets\exe', where 'exe' is the
// directory where are the executable files you want to run from your app:
  Directory directory =
      Directory("$mainPath\\data\\flutter_assets\\assets\\module");
  return directory;
}
