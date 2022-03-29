import 'dart:typed_data';

import 'package:gpmf/screens/videoPlayer/screenshot/models/custommarker.dart';

class Outlets {
  Outlets({required this.outlets});
  List<SingleOutlet> outlets;
}

class SingleOutlet {
  SingleOutlet(
      {required this.currentDuration,
      required this.imageData,
      required this.detail});
  double currentDuration;
  Uint8List imageData;
  CustomMarker detail;
}
