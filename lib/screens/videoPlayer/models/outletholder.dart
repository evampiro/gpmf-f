import 'dart:typed_data';

import 'package:gpmf/screens/videoPlayer/screenshot/models/custommarker.dart';

class Outlets {
  Outlets({required this.outlets, required this.currentDuration});
  List<SingleOutlet> outlets;
  int currentDuration;
}

class SingleOutlet {
  SingleOutlet({required this.imageData, required this.detail});

  Uint8List imageData;
  CustomMarker detail;
}
