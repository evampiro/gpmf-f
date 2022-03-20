// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import "package:gpmf/screens/LocationsClass";
import 'package:gpmf/screens/MapHolder.dart';
import 'package:gpmf/screens/exporter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
// import 'package:geolocator/geolocator.dart';

class AIScreen2 extends StatefulWidget {
  const AIScreen2({Key? key}) : super(key: key);

  @override
  State<AIScreen2> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen2> with TickerProviderStateMixin {
  List<String> consoleText = ["console started"];
  String? file;

  List<LocationsData> original = [], processed = [], mixed = [];
  double constantDistance = 10;
  Duration constantTimeDifference = const Duration(seconds: 8);
  bool isProcessing = false, showErasedData = true;
  MapController controller = MapController(zoom: 17, location: LatLng(0, 0));
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
  }

  final progressStreamProvider = StateProvider<int>((ref) {
    return 0;
  });
  execute(String jsonPath, WidgetRef ref) async {
    DateTime startedAt = DateTime.now();

    List<LocationsData> locations = [];
    List<LocationsData> toRemove = [];
    String contents = await File(jsonPath).readAsString();
    // locations = locationsFromMap(contents);

    List<dynamic> jsonContents = jsonDecode(contents);
    for (var e in jsonContents) {
      locations.add(LocationsData(
          lat: e["value"][0],
          lng: e["value"][1],
          timeStamp: DateTime.parse(e["date"]),
          duplicate: false));
    }
    setState(() {
      original = locations.toList();
    });
    List<LocationsData> nearestList = [];
    _controller.repeat();
    //2157 2441
    for (int i = 0; i < locations.length; i++) {
      {
        await Future.delayed(Duration.zero, () {
          ref.read(progressStreamProvider.state).state =
              ((i / locations.length) * 100).toInt();
        });
        if (!toRemove.contains(locations[i])) {
          for (int y = i; y < locations.length; y++) {
            // print(y);
            var distance = calculateDistance(locations[i].lat, locations[i].lng,
                locations[y].lat, locations[y].lng);
            //print(distance);
            if (distance < constantDistance) {
              // if (!nearestList.contains(locations[y]))
              {
                nearestList.add(locations[y]);
              }
            }
            // else if (distance > constantDistance * 8) {
            //   print("stopped & index is: $y");
            //   break;
            // }
          }
        }

        for (var j in nearestList) {
          //print();
          if (j.timeStamp.difference(locations[i].timeStamp).inSeconds >
              constantTimeDifference.inSeconds) {
            if (!toRemove.contains(j)) {
              toRemove.add(j);
            }
          }
        }
      }
      nearestList = [];
    }

    //
    // ignore: avoid_print
    print("${locations.length} ${toRemove.length}");
    // ignore: unused_local_variable
    int c = 0;
    toRemove.forEach(((element) {
      //locations.remove(element);

      var index = locations.indexWhere((e) => e == element);
      locations[index].duplicate = true;

      c++;
    }));
    mixed = locations.toList();
    toRemove.forEach((element) {
      locations.remove(element);
    });
    controller.center = LatLng(
        original[original.length ~/ 2].lat, original[original.length ~/ 2].lng);

    for (int j = 0; j < mixed.length; j++) {
      if (mixed[j].duplicate) {
        var index = 0;

        for (int i = j; i < mixed.length; i++) {
          if (mixed[i].duplicate == false) {
            index = i;
            break;
          }
        }
        var dataLength = index - j;
        var mappedLength = map(dataLength, 0, 3000, 28, 60);
        print(mappedLength);
        for (int y = index; y > index - mappedLength; y--) {
          if (mixed[y].duplicate) {
            mixed[y].duplicate = false;
          }
        }
        j = index;
      }
    }
    setState(() {
      processed = locations.toList();
      isProcessing = false;
    });
    ref.read(progressStreamProvider.state).state = 0;
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
    // ignore: avoid_print
    print("took ${DateTime.now().difference(startedAt).inSeconds}");
    // String exportable = "[\n";
    // for (int i = 0; i < locations.length; i++) {
    //   exportable += jsonEncode(locations[i].completeString) + ",\n";
    // }

    File(jsonPath.substring(0, jsonPath.length - 5) + "_processed.json")
        .writeAsString(locationsToMap(mixed));
    setState(() {
      consoleText.add("Exported");
    });
    _controller.stop();
    _controller.reset();
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
                        const Text("Show Erased Data: "),
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
                child: Consumer(builder: (context, ref, s) {
                  return GestureDetector(
                    onTap: (() async {
                      if (file != null) {
                        setState(() {
                          isProcessing = true;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          execute(file!, ref);
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
                  );
                }),
              ),
            ]),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  if (original.isNotEmpty)
                    Expanded(
                      child: MapWidget(data: mixed),
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
                    children: consoleText.reversed
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
            child: Builder(builder: (context) {
              return Consumer(builder: (context, ref, s) {
                final progress = ref.watch(progressStreamProvider.state).state;

                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                          animation: _controller,
                          builder: (_, child) {
                            if (_controller.value > 0.6) {
                              return const Icon(Icons.hourglass_full);
                            } else if (_controller.value > 0.3 &&
                                _controller.value < 0.6) {
                              return const Icon(Icons.hourglass_top);
                            } else {
                              return const Icon(Icons.hourglass_empty);
                            }
                          }),
                      const Divider(),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(),
                      const Text("Eliminating Duplicates ...")
                    ],
                  ),
                );
              });
            }),
          )
        ],
      ),
    );
  }

  Stack MapWidget(
      {bool isOriginal = true,
      required List<LocationsData> data,
      bool isLine = true}) {
    controller.addListener(() {
      setState(() {});
    });
    return Stack(
      children: [
        MapScreenHolder(
            isLine: isLine, mapController: controller, coordinates: data),
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
