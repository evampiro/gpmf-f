import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/AIScreen.dart';
import 'package:gpmf/screens/AIv2.dart';
import 'package:gpmf/screens/compress.dart';
import 'package:gpmf/screens/map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:process_run/shell.dart';
import 'package:random_color/random_color.dart';

final DataListProvider = StateProvider<List<GeoFile>>((ref) {
  return [];
});
final MapControllerProvider = Provider<MapController>((ref) {
  return MapController(
    zoom: 17,
    location: LatLng(0, 0),
  );
});

final refreshProvider = StateProvider<int?>((ref) {
  return 0;
});

class GeoFile {
  GeoFile({
    required this.file,
    required this.geoData,
    required this.sample,
    required this.duration,
    required this.color,
  });
  XFile file;

  List<GeoData> geoData;
  int sample, duration;
  Color color;
  Rect? boundingBox;
  Rect boundingBoxLatLng() {
    double minX = double.infinity;
    double maxX = 0;
    double minY = double.infinity;
    double maxY = 0;
    for (int i = 0; i < geoData.length; i++) {
      minX = min(minX, geoData[i].lat);
      minY = min(minY, geoData[i].lon);
      maxX = max(maxX, geoData[i].lat);
      maxY = max(maxY, geoData[i].lon);
    }

    var rec = Rect.fromLTWH(minX, minY, (maxX - minX), (maxY - minY));
    boundingBox = rec;

    //print(rec);
    return rec;
  }
}

class GeoData {
  GeoData({required this.lat, required this.lon, required this.time});
  double lon, lat;
  DateTime time;
}

class Home extends ConsumerWidget {
  Home({Key? key}) : super(key: key);

  final sampleDivisor = 10;
  final mediaControllerProviderLeft = Provider<Player>((ref) {
    return Player(
      id: 69420,
      videoDimensions: const VideoDimensions(1920, 1080),
    );
  });
  final mediaControllerProviderRight = Provider<Player>((ref) {
    return Player(
      id: 69421,
      videoDimensions: const VideoDimensions(1920, 1080),
    );
  });

  final bool _dragging = false;
  // final MapController _controller = MapController(location: LatLng(30, 30));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(DataListProvider.state).state;
    final refresh = ref.watch(DataListProvider.state).state;
    final _controller = ref.watch(MapControllerProvider);
    final leftPlayer = ref.watch(mediaControllerProviderLeft);
    final rightPlayer = ref.watch(mediaControllerProviderRight);
    return Scaffold(
        floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return AIScreen2();
            }));
          },
          child: Container(
            margin: EdgeInsets.all(12),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: Icon(Icons.start),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: DropTarget(
          onDragDone: (detail) async {
            ref.read(DataListProvider.state).state = [];
            List<GeoFile> geoData = [];
            for (final file in detail.files) {
              // debugPrint('  ${file.path} ${file.name}'
              //     '  ${await file.lastModified()}'
              //     '  ${await file.length()}'
              //     '  ${file.mimeType}');

              try {
                var dat = await file.readAsString();
                var json = jsonDecode(dat);

                List<GeoData> data = [];

                for (int i = 0; i < json.length; i++) {
                  data.add(GeoData(
                      lat: json[i]["value"][0],
                      lon: json[i]["value"][1],
                      time: DateTime.parse(json[i]["date"].toString())));
                }

                File filel = File(file.path.replaceAll(".json", ".mp4"));
                // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4');
                //print("last modified: ${await file.lastModified()}");
                Media media = Media.file(
                  // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
                  filel,
                  parse: true,

                  // Media.file(
                );
                var geof = GeoFile(
                    file: file,
                    geoData: data,
                    sample: data.length ~/ sampleDivisor,
                    duration: int.parse(media.metas["duration"]!),
                    color: RandomColor().randomColor(
                        colorSaturation: ColorSaturation.highSaturation,
                        colorHue: ColorHue.multiple(colorHues: [
                          ColorHue.red,
                          ColorHue.orange,
                          ColorHue.blue
                        ])));
                geof.boundingBoxLatLng();
                geoData.add(geof);
              } catch (e, s) {
                print('error $e $s');
                // Navigator.pop(context);
              }
            }
            ref.read(MapControllerProvider).center =
                LatLng(geoData[0].geoData[0].lat, geoData[0].geoData[0].lon);
            ref.read(DataListProvider.state).state = geoData.toList();

            //File file = File('D:/Projects/Backend/sample/long-new-sample.mp4');

            File file = File(geoData[0].file.path.replaceAll(".json", ".mp4"));
            // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4');
            //print("last modified: ${await file.lastModified()}");
            Media media = Media.file(
              // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
              file,
              parse: true,

              // Media.file(
            );
            // print(media.metas["duration"]);
            //player.open(media);
            ref.read(mediaControllerProviderLeft).open(media, autoStart: true);

            // Navigator.pop(context);

            // detail.files.
          },
          onDragEntered: (detail) {
            showDialog(
                barrierDismissible: false,
                barrierColor: Colors.blueGrey.withOpacity(0.5),
                context: context,
                builder: (_) {
                  return const Center(child: Icon(Icons.add));
                });
          },
          onDragExited: (detail) {
            Navigator.pop(context);
          },
          onDragUpdated: (detail) {},
          child: Stack(
            children: [
              Column(
                children: [
                  Visibility(
                    visible: false,
                    child: Container(
                      width: double.infinity,
                      color: _dragging
                          ? Colors.blue.withOpacity(0.4)
                          : Colors.blueGrey,
                      child: const Center(child: Text("Drop here")),
                    ),
                  ),
                  Expanded(
                      flex: 12,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                                color: Colors.grey,
                                child: list.isNotEmpty
                                    ? Consumer(builder: (context, ref, s) {
                                        // final r =
                                        //     ref.watch(refreshProvider.state).state;
                                        return MapScreen(
                                          mapController: _controller,
                                          // markers: getMarkers(list[0]),
                                          geoFile: DataListProvider,
                                          leftPlayerController:
                                              mediaControllerProviderLeft,
                                          rightPlayerController:
                                              mediaControllerProviderLeft,

                                          // markers: [
                                          //   LatLng(list[0].lat!, list[0].lon!),
                                          //   LatLng(list[(list.length - 1) ~/ 2].lat!,
                                          //       list[(list.length - 1) ~/ 2].lon!),
                                          //   LatLng(list[list.length - 1].lat!,
                                          //       list[list.length - 1].lon!)
                                          // ],
                                          // markers: list
                                          //     .map((e) => LatLng(e.lat!, e.lon!))
                                          //     .toList(),
                                        );
                                      })
                                    : const Center(
                                        child: Text('Load Data to visualize'),
                                      )),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                videoPlayer(leftPlayer),
                                videoPlayer(rightPlayer, left: false),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => AlertDialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  content: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .8,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              .8,
                                                      child: CompressScreen()),
                                                ));
                                      },
                                      child: const Text('Tools')),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: list.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          onTap: () {
                                            var control =
                                                ref.read(MapControllerProvider);

                                            control.center = LatLng(
                                                list[index].geoData[0].lat,
                                                list[index].geoData[0].lon);

                                            // control.zoom++;
                                          },
                                          title: Text(
                                              '${list[index].file.name}\nSamples: ${list[index].geoData.length}'),
                                          leading: CircleAvatar(
                                            backgroundColor: list[index].color,
                                          ),
                                          trailing: IconButton(
                                              onPressed: () {},
                                              icon:
                                                  const Icon(Icons.play_arrow)),
                                          subtitle: Consumer(
                                              builder: (context, ref, s) {
                                            final r = ref
                                                .watch(refreshProvider.state)
                                                .state;

                                            return Row(
                                              children: [
                                                const Text('Quality'),
                                                Slider(
                                                  value: list[index]
                                                      .sample
                                                      .toDouble(),
                                                  onChanged: (v) {
                                                    // print(v);
                                                    var tempList = ref
                                                        .read(DataListProvider
                                                            .state)
                                                        .state;

                                                    tempList[index].sample =
                                                        v.toInt();
                                                    ref
                                                        .read(DataListProvider
                                                            .state)
                                                        .state = tempList;
                                                    ref
                                                        .read(refreshProvider
                                                            .state)
                                                        .state = v.toInt();
                                                    // var c = _controller.zoom;
                                                    // _controller.zoom = c;
                                                  },
                                                  onChangeEnd: (v) {},
                                                  min: 1,
                                                  max: list[index]
                                                          .geoData
                                                          .length /
                                                      sampleDivisor,
                                                ),
                                                Text(list[index]
                                                    .sample
                                                    .toDouble()
                                                    .toString())
                                              ],
                                            );
                                          }),
                                          // trailing: Text("${list?[index].time}"),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
                ],
              ),
              // DraggableWidget(
              //   intialVisibility: true,
              //   initialPosition: AnchoringPosition.bottomRight,
              //   bottomMargin: 24,
              //   topMargin: 12,
              //   horizontalSpace: 12,
              //   verticalSpace: 12,
              //   child: Opacity(
              //     opacity: .9,
              //     child: ,
              //   ),
              // )
            ],
          ),
        ));
  }

  List<LatLng> getMarkers(GeoFile data) {
    List<LatLng> temp = [];
    temp = data.geoData.map((e) => LatLng(e.lat, e.lon)).toList();

    // var c = temp.toList();
    // for (var element in temp) {
    //   c.removeWhere((e) =>
    //       element.latitude == e.latitude && element.longitude == e.longitude);
    //   c.add(element);
    // }
    // temp.clear();
    // for (int i = 0; i < c.length; i += data.sample) {
    //   temp.add(LatLng(data.geoData[i].lat, data.geoData[i].lon));
    // }
    // print(temp.length);
    return temp;
  }
}

Stack videoPlayer(Player leftPlayer, {bool left = true}) {
  return Stack(
    children: [
      SizedBox(
        width: 600,
        height: 350,
        child: Video(
          player: leftPlayer,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(left ? "Left" : "Right"),
      )
    ],
  );
}
