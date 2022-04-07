import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/models/custommarker.dart';

class Outlets {
  Outlets(
      {required this.outlets,
      required this.currentDuration,
      required this.mainImageData,
      this.currentPosition = Offset.zero});

  Uint8List mainImageData;
  List<SingleOutlet> outlets;
  int currentDuration;
  Offset currentPosition;
}

class SingleOutlet {
  SingleOutlet({required this.imageData, required this.detail});

  Uint8List imageData;
  CustomMarker detail;
}
