import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/LocationsClass';

class GeoFile {
  GeoFile(
      {required this.file,
      required this.geoData,
      required this.sample,
      required this.duration,
      required this.color,
      required this.isLine});
  XFile file;

  List<LocationsData> geoData;
  int sample, duration;
  Color color;
  Rect? boundingBox;
  bool isLine;
  Rect boundingBoxLatLng() {
    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;
    for (int i = 0; i < geoData.length; i++) {
      minX = min(minX, geoData[i].lat);
      minY = min(minY, geoData[i].lng);
      maxX = max(maxX, geoData[i].lat);
      maxY = max(maxY, geoData[i].lng);
    }

    var rec = Rect.fromLTWH(minX, minY, (maxX - minX), (maxY - minY));
    boundingBox = rec;

    //print(rec);
    return rec;
  }
}
