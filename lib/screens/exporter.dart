import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';

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
