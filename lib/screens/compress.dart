import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:process_run/shell.dart';
import 'package:http/http.dart' as http;

class FileThumb {
  FileThumb({
    required this.file,
    required this.thumbnail,
    required this.filename,
    required this.size,
  });
  File file;
  String thumbnail;
  String filename;

  int size;
}

class CompressScreen extends ConsumerWidget {
  final fileListProvider = StateProvider<List<FileThumb>>((ref) {
    return [];
  });

  final statusStringProvider = StateProvider<List<String>>((ref) {
    return [];
  });

  CompressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = ref.watch(fileListProvider.state).state;
    return Scaffold(
      body: Stack(
        children: [
          files.isEmpty
              ? Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        String? selectedDirectory =
                            await FilePicker.platform.getDirectoryPath();

                        if (selectedDirectory == null) {
                          // User canceled the picker

                        }
                        final List<FileSystemEntity> entities =
                            await Directory(selectedDirectory!)
                                .list(recursive: true)
                                .toList();
                        // entities.forEach((element) {
                        //   print(element);
                        // });
                        final List<FileThumb> files = [];
                        final Iterable<File> iterablefiles =
                            entities.whereType<File>();
                        iterablefiles.forEach((element) async {
                          var thumb = await getThumbnail(element.path);
                          var length = await element.length();
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
                          files.add(
                            FileThumb(
                              file: element,
                              thumbnail: thumb,
                              size: length,
                              filename: element.path.split('\\').toList().last,
                            ),
                          );
                          // player.open(media);
                          // player.seek(const Duration(milliseconds: 0));
                        });
                        ref.read(fileListProvider.state).state = files;
                      },
                      child: const Text('Select Folder')))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: files.length,
                      itemBuilder: (_, index) {
                        // player.seek(const Duration(milliseconds: 0));
                        return Container(
                          color: Colors.grey,
                          child: Stack(
                            children: [
                              // Video(
                              //   showControls: false,
                              //   player: files[index].player,
                              // ),
                              Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      files[index].filename,
                                      textAlign: TextAlign.center,
                                    ),
                                  ))
                            ],
                          ),
                        );
                      }),
                ),
          if (files.isNotEmpty)
            Positioned(
                right: 20,
                bottom: 20,
                child: Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Shell().run(
                              "ffmpeg.exe -i ${files[0].file.path} -vf scale=320:-1 -map 0:0 -map 0:1 -map 0:3 -codec:v mpeg2video -codec:d copy -codec:a copy -y ${files[0].file.path.replaceAll(files[0].filename, "com-${files[0].filename}")}",
                              onProcess: (process) {
                            var stream = process.outLines.asBroadcastStream;
                            stream(
                              onListen: (subscription) {
                                subscription.onData((data) {
                                  print("data: $data");
                                  var l = ref
                                      .read(statusStringProvider.state)
                                      .state;
                                  l.add(data);
                                  ref.read(statusStringProvider.state).state =
                                      l;
                                });
                              },
                            );
                          });
                          // files.forEach((element) {
                          //   Shell().run(
                          //       "ffmpeg.exe -i ${element.file.path} -vf scale=320:-1 -map 0:0 -map 0:1 -map 0:3 -codec:v mpeg2video -codec:d copy -codec:a copy -y ${element.file.path.replaceAll(element.filename, "com-${element.filename}")}",
                          //       onProcess: (process) {
                          //     print(process);
                          //   });
                          // });
                        },
                        child: const Text("Compress All")),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          List<String> paths = [];
                          files.forEach((element) {
                            if (element.filename.contains("com-")) {
                              paths.add(element.file.path);
                            }
                          });
                          var status = await http.post(
                              Uri.parse("http://localhost:4000/api/telemetry"),
                              body: jsonEncode(paths));
                          print(status);
                        },
                        child: const Text("Generate Telemery"))
                  ],
                )),
          // Positioned(
          //   left: 20,
          //   bottom: 20,
          //   child: Consumer(builder: (context, ref, s) {
          //     final status = ref.watch(statusStringProvider.state).state;
          //     return Container(
          //       color: Colors.white,
          //       width: 300,
          //       height: 300,
          //       child: ListView.builder(
          //           itemCount: status.length,
          //           itemBuilder: (_, index) {
          //             return Text(status[index].toString());
          //           }),
          //     );
          //   }),
          // ),
          const Positioned(right: 0, top: 0, child: CloseButton())
        ],
      ),
    );
  }

  getThumbnail(path) async {
    // final data = await VideoThumbnail.thumbnailData(
    //   video: path,
    //   imageFormat: ImageFormat.JPEG,
    //   maxWidth:
    //       128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
    //   quality: 25,
    // );

    return '';
  }
}

//  