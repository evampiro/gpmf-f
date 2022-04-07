import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gpmf/screens/videoPlayer/components/playbackspeed.dart';
import 'package:gpmf/screens/videoPlayer/components/timeline.dart';
import 'package:gpmf/screens/videoPlayer/homeHolder.dart';
import 'package:gpmf/screens/videoPlayer/models/outletholder.dart';
import 'package:gpmf/screens/videoPlayer/screenshot/components/fullscreenshot.dart';
import 'package:gpmf/utilities/intents.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer(
      {Key? key,
      required this.lefPlayer,
      required this.rightPlayer,
      this.left = true,
      required this.duplicateAlertProvider,
      required this.duration,
      this.dual = false})
      : super(key: key);
  final Player lefPlayer, rightPlayer;
  final bool left, dual;
  final StateProvider<bool> duplicateAlertProvider;
  final int duration;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoState();
}

class _VideoState extends ConsumerState<VideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _playController, _modeController;
  List<Outlets> outlet = [];
  final GlobalKey _widgetKey = GlobalKey();
  double height1 = 0.7, height2 = 0.3;
  @override
  void initState() {
    super.initState();
    _playController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _modeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    IntentFunctions().onSKey = () async {
      int currentindex = ref.read(currentPageIndexProvider.state).state;
      print(currentindex);
      if (currentindex == 1 && widget.lefPlayer.current.medias.isNotEmpty) {
        if (widget.lefPlayer.playback.isPlaying) widget.lefPlayer.pause();
        var tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        File temp = File(tempPath + "temp.png");
        widget.lefPlayer.takeSnapshot(temp, 1920, 1080);
        // RenderRepaintBoundary boundary = _globalKey.currentContext!
        //     .findRenderObject()! as RenderRepaintBoundary;
        // ui.Image image = await boundary.toImage(
        //     pixelRatio: MediaQuery.of(context).devicePixelRatio);
        // ByteData? byteData =
        //     await image.toByteData(format: ui.ImageByteFormat.png);
        // final Uint8List? imageData = byteData?.buffer.asUint8List();
        var data = temp.readAsBytesSync();
        await Navigator.push(context, MaterialPageRoute(builder: (_) {
          return FullScreenShot(
            duration: widget.lefPlayer.position.position!.inMilliseconds,
            outlet: outlet,
            imageData: data,
          );
        }));
        setState(() {});
      }
    };
  }

  Offset dragPosition = const Offset(0, 0);

  @override
  void dispose() {
    _playController.dispose();
    _modeController.dispose();
    widget.lefPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      widget.lefPlayer.playbackStream.listen((event) {
        if (event.isPlaying) {
          _playController.forward();
        } else {
          _playController.reverse();
        }
      });
      return Column(
        children: [
          Container(
            height: height1 * constraints.maxHeight,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InteractiveViewer(
                        panEnabled: false,
                        minScale: 1,
                        maxScale: 3,
                        child: SizedBox(
                          width: constraints.maxWidth / 2,
                          height: constraints.maxHeight,
                          child: Video(
                            showControls: false,
                            player: widget.lefPlayer,
                          ),
                        ),
                        onInteractionUpdate: (details) {
                          print(details.scale);
                        },
                      ),
                    ),
                    if (widget.dual)
                      Expanded(
                        child: InteractiveViewer(
                          panEnabled: false,
                          minScale: 1,
                          maxScale: 3,
                          child: SizedBox(
                            width: constraints.maxWidth / 2,
                            height: constraints.maxHeight,
                            child: Video(
                              showControls: false,
                              player: widget.rightPlayer,
                            ),
                          ),
                          onInteractionUpdate: (details) {
                            print(details.scale);
                          },
                        ),
                      ),
                  ],
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        ...[
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (widget.lefPlayer.position.position!
                                        .inMilliseconds >
                                    5000) {
                                  widget.lefPlayer.seek(Duration(
                                      milliseconds: widget.lefPlayer.position
                                              .position!.inMilliseconds -
                                          5000));
                                  widget.rightPlayer.seek(Duration(
                                      milliseconds: widget.lefPlayer.position
                                              .position!.inMilliseconds -
                                          5000));
                                }
                              },
                              child: Icon(Icons.replay_5),
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (widget.lefPlayer.playback.isPlaying) {
                                  _playController.reverse();

                                  widget.lefPlayer.pause();
                                  widget.rightPlayer.pause();
                                } else {
                                  _playController.forward();

                                  widget.lefPlayer.play();
                                  widget.rightPlayer.play();
                                }
                              },
                              child: AnimatedIcon(
                                  icon: AnimatedIcons.play_pause,
                                  progress: _playController),
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: PopupMenuButton(
                                offset: getOffset(),
                                tooltip: '',
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      enabled: false,
                                      child: PlayBackSpeed(
                                        key: _widgetKey,
                                        player: widget.lefPlayer,
                                      ),
                                    )
                                  ];
                                },
                                child: Icon(Icons.slow_motion_video)),
                          ),
                        ],
                        const Spacer(),
                        StatefulBuilder(builder: (context, setStatemini) {
                          var duration = Duration(minutes: 0);
                          // widget.lefPlayer.playbackCont.listen(
                          //   (event) {
                          //     duration=event.
                          //   },
                          // );
                          return SizedBox(
                            width: 100,
                            child: Text((widget.lefPlayer.position.position)
                                .toString()),
                          );
                        })
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: height2 * constraints.maxHeight,
            width: constraints.maxWidth * .95,
            child: Stack(
              children: [
                TimeLine(
                  outlets: outlet,
                  leftplayer: widget.lefPlayer,
                  rightplayer: widget.rightPlayer,
                  duration: widget.duration,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: Draggable(
                    onDragUpdate: (details) {
                      // print(details.delta.dy / 10);

                      setState(() {
                        height1 += details.delta.dy / 1000;
                        height2 -= details.delta.dy / 1000;
                      });
                    },
                    axis: Axis.vertical,
                    feedback: Container(
                      // width: double.infinity,
                      height: 6,
                      color: Colors.transparent,
                    ),
                    childWhenDragging: Container(
                      height: 6,
                      color: Colors.blue,
                    ),
                    child: Container(
                      // width: double.infinity,
                      height: 6,
                      color: Colors.transparent,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      );
    });
  }

  Offset getOffset() {
    // final RenderBox renderBox =
    //     _widgetKey.currentContext!.findRenderObject() as RenderBox;
    // print(_widgetKey.currentContext?.size);
    if (_widgetKey.currentContext != null) {
      final RenderBox renderBox =
          _widgetKey.currentContext!.findRenderObject() as RenderBox;
      print(_widgetKey.currentContext?.size);
      return renderBox.localToGlobal(Offset.zero);
    } else {
      return Offset.zero;
    }
  }
}
