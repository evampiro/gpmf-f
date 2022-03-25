import 'package:flutter/material.dart';
import 'package:latlng/latlng.dart';

class CustomMarker {
  CustomMarker(
      {required this.position,
      required this.color,
      this.selected = false,
      required this.id});
  Offset position;
  Color color;
  LatLng? gps;
  String? name, category;
  bool selected;
  int id;
}
