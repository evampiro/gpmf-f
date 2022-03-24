import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _modeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  Offset dragPosition = Offset(0, 0);

  @override
  void dispose() {
    // TODO: implement dispose
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
      return Column(
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
                          if (widget.player.position.position!.inMilliseconds >
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
      );
    });
  }
}
