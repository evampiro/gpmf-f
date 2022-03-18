import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/MapHolder.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
// import 'package:geolocator/geolocator.dart';

class AIScreen2 extends StatefulWidget {
  const AIScreen2({Key? key}) : super(key: key);

  @override
  State<AIScreen2> createState() => _AIScreenState();
}

class Location {
  final double lat;
  final double lng;
  final DateTime timeStamp;
  //final Map<String, dynamic> completeString;
  Location(this.lat, this.lng, this.timeStamp);
}

class _AIScreenState extends State<AIScreen2> {
  List<String> consoleText = ["console started"];
  String? file;

  List<Location> original = [], processed = [];
  double constantDistance = 10;
  Duration constantTimeDifference = const Duration(seconds: 8);
  bool isProcessing = false, showErasedData = true;
  MapController controller = MapController(zoom: 17, location: LatLng(0, 0));
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  execute(String jsonPath) async {
    DateTime startedAt = DateTime.now();

    List<Location> locations = [];
    List<Location> toRemove = [];
    String contents = await File(jsonPath).readAsString();

    List<dynamic> jsonContents = jsonDecode(contents);
    jsonContents.forEach((e) {
      locations.add(
          Location(e["value"][0], e["value"][1], DateTime.parse(e["date"])));
    });
    setState(() {
      original = locations.toList();
    });
    List<Location> nearestList = [];
    //2157 2441
    // for (int q = 0; q < locations.length; q++) {
    int i = 2186;
    if (i > 2157 && i < 2437) {
      if (!toRemove.contains(locations[i])) {
        int maxError = 0;
        DateTime? errorTimeStamp;
        for (int y = i; y < locations.length; y++) {
          // print(y);
          var distance = calculateDistance(locations[i].lat, locations[i].lng,
              locations[y].lat, locations[y].lng);
          //print(distance);
          if (distance < constantDistance) {
            // if (!nearestList.contains(locations[y]))
            {
              if (errorTimeStamp != null) {
                maxError =
                    locations[y].timeStamp.difference(errorTimeStamp).inSeconds;
              }
              if (locations[y]
                          .timeStamp
                          .difference(locations[i].timeStamp)
                          .inSeconds -
                      maxError >
                  constantTimeDifference.inSeconds) {
                errorTimeStamp ??= locations[y].timeStamp;
                print(errorTimeStamp);
                nearestList.add(locations[y]);
              }
              print(
                  "${locations[y].timeStamp.difference(locations[i].timeStamp).inSeconds} ${constantTimeDifference.inSeconds + maxError}");
            }
            // } else if (distance > constantDistance * 8) {
            // print("stopped & index is: $y");
            // break;
          }
        }

        for (var j in nearestList) {
          //print();

          if (!toRemove.contains(j)) {
            toRemove.add(j);
          }
        }
      }
    }

    nearestList = [];
    // }
    //
    print("${locations.length} ${toRemove.length}");
    int c = 0;
    toRemove.forEach(((element) {
      locations.remove(element);
      c++;
    }));
    controller.center = LatLng(
        original[original.length ~/ 2].lat, original[original.length ~/ 2].lng);
    setState(() {
      processed = locations.toList();
      isProcessing = false;
    });

    // for (int i = 0; i < locations.length; i++) {
    //   for (int j = 0; j < locations.length; j++) {}
    //   if (i % 1000 == 0) {
    //     print("$i, ${toRemove.length}");
    //     setState(() {
    //       consoleText.add(
    //           "$i completed out of ${locations.length}, ${toRemove.length} duplicates");
    //     });
    //   }
    // }

    // for (int i = locations.length - 1; i > -1; i--) {
    //   if (toRemove.contains(i)) {
    //     locations.removeAt(i);
    //   }
    // }
    // print("\n\n length is coming");
    // print(
    //     "${locations.length}, ${toRemove.length} duplicates in ${DateTime.now().difference(startedAt).inMinutes}");

    // setState(() {
    //   consoleText.add("All completed");
    //   consoleText.add(
    //       "${locations.length}, ${toRemove.length} duplicates in ${DateTime.now().difference(startedAt).inMinutes}m");
    // });

    // String exportable = "[\n";
    // for (int i = 0; i < locations.length; i++) {
    //   exportable += jsonEncode(locations[i].completeString) + ",\n";
    // }
    // exportable += "\n]";
    // File(jsonPath.substring(0, jsonPath.length - 5) + "_output.json")
    //     .writeAsString(exportable);
    // setState(() {
    //   consoleText.add("Exported");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [
            AppBar(actions: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: (() async {
                    FilePickerResult? fileresult = await FilePicker.platform
                        .pickFiles(allowMultiple: false);
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
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        const Text("Max Search Distance (m):  "),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(
                                text: constantDistance.toString()),
                            onChanged: (v) {
                              if (v.isNotEmpty) {
                                constantDistance = double.parse(v);
                              }
                            },
                          ),
                        ),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      children: [
                        const Text("Duration (s):  "),
                        Expanded(
                            child: TextField(
                          controller: TextEditingController(
                            text: constantTimeDifference.inSeconds.toString(),
                          ),
                          onChanged: (v) {
                            if (v.isNotEmpty) {
                              constantTimeDifference =
                                  Duration(seconds: int.parse(v));
                            }
                          },
                        )),
                      ],
                    )),
                    Row(
                      children: [
                        Text("Show Erased Data: "),
                        Checkbox(
                            value: showErasedData,
                            onChanged: (v) {
                              setState(() {
                                showErasedData = v!;
                              });
                            }),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: (() async {
                    if (file != null) {
                      setState(() {
                        isProcessing = true;
                      });
                      Future.delayed(const Duration(milliseconds: 100), () {
                        execute(file!);
                      });
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
              flex: 5,
              child: Row(
                children: [
                  if (original.isNotEmpty)
                    Expanded(
                      child: MapWidget(data: original),
                    ),
                  Container(
                    width: 10,
                    color: Colors.grey,
                  ),
                  if (processed.isNotEmpty)
                    Expanded(
                        child: MapWidget(
                            data: processed,
                            isOriginal: false,
                            isLine: !showErasedData)),
                ],
              ),
            ),
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
          Visibility(
            visible: isProcessing,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.hourglass_full),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Processing"),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Stack MapWidget(
      {bool isOriginal = true,
      required List<Location> data,
      bool isLine = true}) {
    controller.addListener(() {
      setState(() {});
    });
    return Stack(
      children: [
        MapScreenHolder(
            isLine: isLine,
            mapController: controller,
            coordinates: data.map((e) => LatLng(e.lat, e.lng)).toList()),
        Container(
          // width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
          ),
          child: Text(
              "${isOriginal ? 'Original data: Samples ${data.length}' : 'Processed data:'}  ${!isOriginal ? " Samples: ${data.length}" : ""}"),
        )
      ],
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
