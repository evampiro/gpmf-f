// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/homeHolder.dart';
import 'package:gpmf/screens/videoPlayer/models/GeofileClass.dart';
import 'package:gpmf/screens/LocationsClass';
import 'package:gpmf/screens/compress/compress.dart';
import 'package:gpmf/utilities/intents.dart';
import 'package:gpmf/screens/videoPlayer/components/map.dart';
import 'package:gpmf/screens/videoPlayer/components/videoPlayer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';
import 'package:random_color/random_color.dart';
// import 'package:screenshot/screenshot.dart';

Random rand = Random();
final DataListProvider = StateProvider<List<GeoFile>>((ref) {
  return [];
});
final MapControllerProvider = Provider<MapController>((ref) {
  return MapController(
    zoom: 17,
    location: LatLng(0, 0),
  );
});
final mediaControllerProviderLeft = Provider<Player>((ref) {
  return Player(
    id: rand.nextInt(5000) + 1,
    videoDimensions: const VideoDimensions(1920, 1080),
  );
});

final refreshProvider = StateProvider<int?>((ref) {
  return 0;
});

class Home extends ConsumerStatefulWidget {
  const Home({Key? key, this.videoPlayer = false}) : super(key: key);
  final bool videoPlayer;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final sampleDivisor = 2;

  final mediaControllerProviderRight = Provider<Player>((ref) {
    return Player(
      id: rand.nextInt(5000) + 2,
      videoDimensions: const VideoDimensions(1920, 1080),
    );
  });
  final duplicateAlertProvider = StateProvider<bool>((ref) {
    return false;
  });
  final bool _dragging = false;
  // final MapController _controller = MapController(location: LatLng(30, 30));
  final skipDuplicateProvider = StateProvider<bool>((ref) {
    return true;
  });
  // final directionModeProvider = StateProvider<bool>((ref) {
  //   return true;
  // });

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10), () {
      // ref.read(spaceIntentProvider.state).state = () {
      //   try {
      //     ref.read(mediaControllerProviderLeft).playOrPause();
      //   } catch (e, s) {
      //     print(e);
      //   }
      // };
    });
  }

  // final ScreenshotController screenShotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    final list = ref.watch(DataListProvider.state).state;
    // ignore: unused_local_variable
    final refresh = ref.watch(DataListProvider.state).state;
    final _controller = ref.watch(MapControllerProvider);
    final leftPlayer = ref.watch(mediaControllerProviderLeft);
    final rightPlayer = ref.watch(mediaControllerProviderRight);

    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      return DropTarget(
        onDragDone: (detail) async {
          ref.read(DataListProvider.state).state = [];
          String replacer = '';
          List<GeoFile> geoData = [];
          for (final file in detail.files) {
            // debugPrint('  ${file.path} ${file.name}'
            //     '  ${await file.lastModified()}'
            //     '  ${await file.length()}'
            //     '  ${file.mimeType}');

            try {
              var dat = await file.readAsString();
              var json = jsonDecode(dat);

              List<LocationsData> data = [];
              if (file.path.contains("_processed")) {
                data = locationsFromMap(dat);
                replacer = '_processed.json';
              } else {
                replacer = '.json';
                for (int i = 0; i < json.length; i++) {
                  data.add(LocationsData(
                      lat: json[i]["value"][0],
                      lng: json[i]["value"][1],
                      timeStamp: DateTime.parse(json[i]["date"].toString()),
                      duplicate: false));
                }
              }

              //print(data[0].time.difference(data.last.time).inMilliseconds);

              File filel = File(file.path.replaceAll(replacer, ".mp4"));

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
                  // sample: data.length ~/ sampleDivisor,
                  sample: 1,
                  duration: int.parse(media.metas["duration"]!),
                  isLine: true,
                  color: RandomColor().randomColor(
                      colorSaturation: ColorSaturation.highSaturation,
                      colorHue: ColorHue.multiple(colorHues: [
                        ColorHue.yellow,
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
              LatLng(geoData[0].geoData[0].lat, geoData[0].geoData[0].lng);
          ref.read(DataListProvider.state).state = geoData.toList();

          //File file = File('D:/Projects/Backend/sample/long-new-sample.mp4');

          File file = File(geoData[0].file.path.replaceAll(replacer, ".mp4"));
          // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4');
          //print("last modified: ${await file.lastModified()}");
          Media media = Media.file(
            // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
            file,
            parse: true,

            // Media.file(
          );

          // Media newMedia =
          //     Media.network("http://videotest.loca.lt/video/long-p-sample.MP4");

          // print(media.metas["duration"]);
          //player.open(media);
          ref.read(mediaControllerProviderLeft).open(media, autoStart: false);
          // ref.read(spaceIntentProvider.state).state = () {
          //   leftPlayer.playOrPause();
          // };
          IntentFunctions().onSpace = () {
            leftPlayer.playOrPause();
          };
          IntentFunctions().onArrowLeft = () {
            if (leftPlayer.position.position!.inMilliseconds > 5000) {
              leftPlayer.seek(Duration(
                  milliseconds:
                      leftPlayer.position.position!.inMilliseconds - 5000));
            }
          };
        },
        // Navigator.pop(context);

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
                    child: Column(
                      children: [
                        Visibility(
                          visible: true,
                          child: Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: !widget.videoPlayer
                                          ? constraints.maxHeight
                                          : 500,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: VideoPlayer(
                                              duration: list.isNotEmpty
                                                  ? list[0].duration
                                                  : 0,
                                              lefPlayer: leftPlayer,
                                              rightPlayer: rightPlayer,
                                              duplicateAlertProvider:
                                                  duplicateAlertProvider,
                                            ),
                                          ),
                                          // if (widget.videoPlayer)
                                          //   Expanded(
                                          //     child: VideoPlayer(
                                          //       duration: list.isNotEmpty
                                          //           ? list[0].duration
                                          //           : 0,
                                          //       player: leftPlayer,
                                          //       duplicateAlertProvider:
                                          //           duplicateAlertProvider,
                                          //       left: false,
                                          //     ),
                                          //   ),
                                          // Consumer(
                                          //     builder: (context, ref, c) {

                                          //   final Size size = Size(50, 50);
                                          //   final child = SizedBox(
                                          //     width: size.width,
                                          //     height: size.height,
                                          //     child: const FlutterLogo(),
                                          //   );
                                          //   return Positioned(
                                          //     left: dragOffset.dx,
                                          //     top: dragOffset.dy,
                                          //     child: Draggable(
                                          //       child: child,
                                          //       feedback: child,
                                          //       onDragEnd: (drag) {
                                          //         print(drag.offset);
                                          //         ref
                                          //                 .read(
                                          //                     dragOffsetProvider
                                          //                         .state)
                                          //                 .state =
                                          //             Offset(
                                          //                 drag.offset.dx,
                                          //                 drag.offset.dy -
                                          //                     size.height *
                                          //                         1.55);
                                          //       },
                                          //       childWhenDragging:
                                          //           Container(),
                                          //     ),
                                          //   );
                                          // })
                                        ],
                                      ),
                                    ),
                                    if (list.isNotEmpty && !widget.videoPlayer)
                                      Visibility(
                                        visible: true,
                                        child: Positioned(
                                          left: 20,
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .335,
                                          child: Opacity(
                                            opacity: 0.95,
                                            child: ClipOval(
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .12,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .12,
                                                child: MapScreen(
                                                  mode: widget.videoPlayer,
                                                  duplicateAlertProvider:
                                                      duplicateAlertProvider,
                                                  skipDuplicateProvider:
                                                      skipDuplicateProvider,
                                                  mapController: _controller,
                                                  interactive: true,
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
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                                // videoPlayer(rightPlayer, left: false),
                                if (widget.videoPlayer)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Consumer(builder: (context, ref, s) {
                                          final skipDuplicate = ref
                                              .watch(
                                                  skipDuplicateProvider.state)
                                              .state;
                                          return Row(
                                            children: [
                                              Checkbox(
                                                  value: skipDuplicate,
                                                  onChanged: (v) {
                                                    ref
                                                        .read(
                                                            skipDuplicateProvider
                                                                .state)
                                                        .state = v!;
                                                  }),
                                              const Text(
                                                  "Skip Duplicate Video"),
                                            ],
                                          );
                                        }),
                                        const Spacer(),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (_) {
                                                return HomeHolder();
                                              }));
                                            },
                                            icon: Icon(Icons.clean_hands)),
                                        ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (_) => AlertDialog(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        content: SizedBox(
                                                            width:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .8,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                .8,
                                                            child:
                                                                CompressScreen()),
                                                      ));
                                            },
                                            child: const Text('Tools')),
                                      ],
                                    ),
                                  ),
                                if (widget.videoPlayer)
                                  Visibility(
                                    visible: false,
                                    child: Expanded(
                                      child: ListView.builder(
                                          itemCount: list.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              onTap: () {
                                                var control = ref.read(
                                                    MapControllerProvider);

                                                control.center = LatLng(
                                                    list[index].geoData[0].lat,
                                                    list[index].geoData[0].lng);

                                                // control.zoom++;
                                              },
                                              title: Text(
                                                  '${list[index].file.name}\nSamples: ${list[index].geoData.length}'),
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    list[index].color,
                                              ),
                                              trailing: Consumer(
                                                  builder: (context, ref, s) {
                                                // ignore: unused_local_variable
                                                final r = ref
                                                    .watch(
                                                        refreshProvider.state)
                                                    .state;
                                                return Checkbox(
                                                  value: list[index].isLine,
                                                  onChanged: (v) {
                                                    // print(v);
                                                    var tempList = ref
                                                        .read(DataListProvider
                                                            .state)
                                                        .state;
                                                    tempList[index].isLine = v!;
                                                    ref
                                                        .read(DataListProvider
                                                            .state)
                                                        .state = tempList;
                                                    var a = Random();
                                                    ref
                                                        .read(refreshProvider
                                                            .state)
                                                        .state = a.nextInt(100);
                                                  },
                                                );
                                              }),
                                              // IconButton(
                                              //     onPressed: () {},
                                              //     icon:
                                              //         const Icon(Icons.play_arrow)),
                                              subtitle: Consumer(
                                                  builder: (context, ref, s) {
                                                // ignore: unused_local_variable
                                                final r = ref
                                                    .watch(
                                                        refreshProvider.state)
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
                                                            .read(
                                                                DataListProvider
                                                                    .state)
                                                            .state;

                                                        tempList[index].sample =
                                                            v.toInt();
                                                        ref
                                                            .read(
                                                                DataListProvider
                                                                    .state)
                                                            .state = tempList;
                                                        ref
                                                            .read(
                                                                refreshProvider
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
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.videoPlayer)
                          Expanded(
                            flex: 4,
                            child: Container(
                                color: Colors.grey,
                                child: list.isNotEmpty
                                    ? Consumer(builder: (context, ref, s) {
                                        // final r =
                                        //     ref.watch(refreshProvider.state).state;
                                        return MapScreen(
                                          mode: widget.videoPlayer,
                                          duplicateAlertProvider:
                                              duplicateAlertProvider,
                                          skipDuplicateProvider:
                                              skipDuplicateProvider,
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
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                                'Load Data to visualize'),
                                            IconButton(
                                                onPressed: () async {
                                                  here:
                                                  String? selectedDirectory =
                                                      await FilePicker.platform
                                                          .getDirectoryPath();

                                                  if (selectedDirectory ==
                                                      null) {
                                                    // User canceled the picker

                                                  }
                                                  final List<FileSystemEntity>
                                                      entities =
                                                      await Directory(
                                                              selectedDirectory!)
                                                          .list(recursive: true)
                                                          .toList();
                                                  // entities.forEach((element) {
                                                  //   print(element);
                                                  // });
                                                  List<FileThumb> files = [];
                                                  final Iterable<File>
                                                      iterablefiles = entities
                                                          .whereType<File>();
                                                  // ignore: avoid_function_literals_in_foreach_calls
                                                  iterablefiles
                                                      .forEach((element) {
                                                    var thumb = '';
                                                    // var length =
                                                    //     await element.length();
                                                    // var player = Player(
                                                    //     id: Random().nextInt(1000),
                                                    //     videoDimensions:
                                                    //         const VideoDimensions(1920, 1080));
                                                    // Media media = Media.file(
                                                    //   // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
                                                    //   element,
                                                    //   parse: true,

                                                    //   // Media.file(
                                                    // );
                                                    // print(element.path);
                                                    if (element.path
                                                        .contains(".json"))
                                                      files.add(
                                                        FileThumb(
                                                          file: element,
                                                          thumbnail: thumb,
                                                          size: 0,
                                                          filename: element.path
                                                              .split('\\')
                                                              .toList()
                                                              .last,
                                                        ),
                                                      );

                                                    // player.open(media);
                                                    // player.seek(const Duration(milliseconds: 0));
                                                    // print(files.length);
                                                  });

                                                  ref
                                                      .read(DataListProvider
                                                          .state)
                                                      .state = [];

                                                  List<GeoFile> tempFiles = [];

                                                  for (var element in files) {
                                                    XFile n = XFile(
                                                        element.file.path);
                                                    var dat =
                                                        await n.readAsString();
                                                    var json = jsonDecode(dat);
                                                    String replacer = '';
                                                    List<LocationsData> data =
                                                        [];
                                                    if (n.path.contains(
                                                        "_processed")) {
                                                      data =
                                                          locationsFromMap(dat);
                                                      replacer =
                                                          '_processed.json';
                                                    } else {
                                                      replacer = '.json';
                                                      for (int i = 0;
                                                          i < json.length;
                                                          i++) {
                                                        data.add(LocationsData(
                                                            lat: json[i]
                                                                ["value"][0],
                                                            lng: json[i]
                                                                ["value"][1],
                                                            timeStamp: DateTime
                                                                .parse(json[i]
                                                                        ["date"]
                                                                    .toString()),
                                                            duplicate: false));
                                                      }
                                                    }

                                                    //print(data[0].time.difference(data.last.time).inMilliseconds);

                                                    File filel = File(n.path
                                                        .replaceAll(
                                                            replacer, ".mp4"));

                                                    // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4');
                                                    //print("last modified: ${await file.lastModified()}");
                                                    Media media = Media.file(
                                                      // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
                                                      filel,
                                                      parse: true,

                                                      // Media.file(
                                                    );
                                                    tempFiles.add(GeoFile(
                                                        file: n,
                                                        geoData: data,
                                                        sample: 1,
                                                        duration: int.parse(
                                                            media.metas[
                                                                "duration"]!),
                                                        color: Colors.red,
                                                        isLine: true));
                                                  }

                                                  // ref.read(fileListProvider.state).state = files;
                                                  print(tempFiles.length);
                                                  List<String> left = [],
                                                      right = [];
                                                  tempFiles.forEach((element) {
                                                    File file = File(element
                                                        .file.path
                                                        .replaceAll(
                                                            '.json', ".mp4"));
                                                    if (element.file.path
                                                        .contains('\\L'))
                                                      left.add(file.path
                                                          .replaceAll(
                                                              ".json", ".mp4"));
                                                    else if (element.file.path
                                                        .contains('\\R'))
                                                      right.add(file.path
                                                          .replaceAll(
                                                              ".json", ".mp4"));
                                                  });
                                                  //print(left[0]);
                                                  Media mediaL = Media.file(
                                                    // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
                                                    File(left[0]),
                                                    parse: true,

                                                    // Media.file(
                                                  );
                                                  Media mediaR = Media.file(
                                                    // File('D:/hilife/Projects/Backend/gpmf/long-new-sample.mp4'),
                                                    File(right[0]),
                                                    parse: true,

                                                    // Media.file(
                                                  );

                                                  ref
                                                      .read(
                                                          mediaControllerProviderLeft)
                                                      .open(mediaL,
                                                          autoStart: false);
                                                  ref
                                                      .read(
                                                          mediaControllerProviderRight)
                                                      .open(mediaR,
                                                          autoStart: false);
                                                  ref
                                                          .read(
                                                              MapControllerProvider)
                                                          .center =
                                                      LatLng(
                                                          tempFiles[0]
                                                              .geoData[0]
                                                              .lat,
                                                          tempFiles[0]
                                                              .geoData[0]
                                                              .lng);
                                                  ref
                                                          .read(DataListProvider
                                                              .state)
                                                          .state =
                                                      tempFiles.toList();
                                                },
                                                icon: Icon(Icons.folder_open)),
                                          ],
                                        ),
                                      )),
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
      );
    }));
  }

  List<LatLng> getMarkers(GeoFile data) {
    List<LatLng> temp = [];
    temp = data.geoData.map((e) => LatLng(e.lat, e.lng)).toList();

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
