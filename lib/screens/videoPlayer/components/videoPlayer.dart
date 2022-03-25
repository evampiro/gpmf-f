import 'dart:io';
import 'dart:typed_data';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/components/fullscreenshot.dart';
import 'package:gpmf/screens/videoPlayer/homeHolder.dart';
import 'package:gpmf/utilities/intents.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer({
    Key? key,
    required this.player,
    this.left = true,
    required this.duplicateAlertProvider,
  }) : super(key: key);
  final Player player;
  final bool left;
  final StateProvider<bool> duplicateAlertProvider;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoState();
}

class _VideoState extends ConsumerState<VideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _playController, _modeController;

  final GlobalKey _globalKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _playController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _modeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    IntentFunctions().onSKey = () async {
      int currentindex = ref.read(currentPageIndexProvider.state).state;
      if (currentindex == 1 && widget.player.current.medias.isNotEmpty) {
        if (widget.player.playback.isPlaying) widget.player.pause();
        var tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        File temp = File(tempPath + "temp.png");
        widget.player.takeSnapshot(temp, 1920, 1080);
        // RenderRepaintBoundary boundary = _globalKey.currentContext!
        //     .findRenderObject()! as RenderRepaintBoundary;
        // ui.Image image = await boundary.toImage(
        //     pixelRatio: MediaQuery.of(context).devicePixelRatio);
        // ByteData? byteData =
        //     await image.toByteData(format: ui.ImageByteFormat.png);
        // final Uint8List? imageData = byteData?.buffer.asUint8List();
        var data = temp.readAsBytesSync();
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return FullScreenShot(
            imageData: data,
          );
        }));
      }
    };
  }

  Offset dragPosition = const Offset(0, 0);

  @override
  void dispose() {
    _playController.dispose();
    _modeController.dispose();
    widget.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      widget.player.playbackStream.listen((event) {
        if (event.isPlaying) {
          _playController.forward();
        } else {
          _playController.reverse();
        }
      });
      return RepaintBoundary(
        key: _globalKey,
        child: Column(
          children: [
            Stack(
              children: [
                InteractiveViewer(
                  panEnabled: false,
                  minScale: 1,
                  maxScale: 3,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Video(
                      showControls: false,
                      player: widget.player,
                    ),
                  ),
                  onInteractionUpdate: (details) {
                    print(details.scale);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.left ? "Left" : "Right"),
                ),
                Positioned.fill(
                  child: Consumer(builder: (context, ref, s) {
                    final duplicateBool =
                        ref.watch(widget.duplicateAlertProvider.state).state;
                    return Visibility(
                      visible: duplicateBool,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            border: Border.all(color: Colors.red, width: 8)),
                        child: const Center(
                          child: Text(
                            'Potential Duplicate',
                            style: TextStyle(fontSize: 55, color: Colors.red),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.grey,
                    height: 45,
                    width: constraints.maxWidth,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (widget
                                    .player.position.position!.inMilliseconds >
                                5000) {
                              widget.player.seek(Duration(
                                  milliseconds: widget.player.position.position!
                                          .inMilliseconds -
                                      5000));
                            }
                          },
                          child: Icon(Icons.replay_5),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (widget.player.playback.isPlaying) {
                              _playController.reverse();

                              widget.player.pause();
                            } else {
                              _playController.forward();

                              widget.player.play();
                            }
                          },
                          child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _playController),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}