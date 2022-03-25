// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({Key? key}) : super(key: key);

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class Location {
  final double lat;
  final double lng;
  final DateTime timeStamp;
  final Map<String, dynamic> completeString;
  Location(this.lat, this.lng, this.timeStamp, this.completeString);
}

class _AIScreenState extends State<AIScreen> {
  List<String> consoleText = ["console started"];
  String? file;

  @override
  void initState() {
    super.initState();
  }

  execute(String jsonPath) async {
    DateTime startedAt = DateTime.now();
    double constantDistance = 50;
    Duration constantTimeDifference = const Duration(minutes: 2);

    List<Location> locations = [];
    List<int> toRemove = [];
    String contents = await File(jsonPath).readAsString();
    List<dynamic> jsonContents = jsonDecode(contents);
    for (var e in jsonContents) {
      locations.add(
          Location(e["value"][0], e["value"][1], DateTime.parse(e["date"]), e));
    }

    for (int i = 0; i < locations.length; i++) {
      for (int j = 0; j < locations.length; j++) {
        if (i != j && !toRemove.contains(i) && !toRemove.contains(j)) {
          if (locations[i].timeStamp.difference(locations[j].timeStamp) >
                  constantTimeDifference &&
              calculateDistance(locations[i].lat, locations[i].lng,
                      locations[j].lat, locations[j].lng) <
                  constantDistance) {
            toRemove.add(i);
          }
        }
      }
      if (i % 1000 == 0) {
        print("$i, ${toRemove.length}");
        setState(() {
          consoleText.add(
              "$i completed out of ${locations.length}, ${toRemove.length} duplicates");
        });
      }
    }

    for (int i = locations.length - 1; i > -1; i--) {
      if (toRemove.contains(i)) {
        locations.removeAt(i);
      }
    }
    print("\n\n length is coming");
    print(
        "${locations.length}, ${toRemove.length} duplicates in ${DateTime.now().difference(startedAt).inMinutes}");

    setState(() {
      consoleText.add("All completed");
      consoleText.add(
          "${locations.length}, ${toRemove.length} duplicates in ${DateTime.now().difference(startedAt).inMinutes}m");
    });

    String exportable = "[\n";
    for (int i = 0; i < locations.length; i++) {
      if (i != locations.length - 1) {
        exportable += jsonEncode(locations[i].completeString) + ",\n";
      }
    }
    exportable += "\n]";
    File(jsonPath.substring(0, jsonPath.length - 5) + "_output.json")
        .writeAsString(exportable);
    setState(() {
      consoleText.add("Exported");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        AppBar(actions: [
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: (() async {
                FilePickerResult? fileresult =
                    await FilePicker.platform.pickFiles(allowMultiple: false);
                if (fileresult != null) {
                  file = fileresult.files[0].path;
                }
                setState(() {});
              }),
              child: Container(
                height: 60,
                width: 100,
                color: Colors.green,
                child: Center(
                  child: Text(
                    file ?? "PICK FILE",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: (() {
                if (file != null) {
                  execute(file!);
                }
              }),
              child: Container(
                height: 60,
                width: 100,
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    "Start",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ]),
        Expanded(
          child: Container(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView(
                children: consoleText
                    .map((e) => Text(
                          e.toString(),
                          style: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    var f = ((12742 * asin(sqrt(a))) * 1000);
    return f;
  }
}
