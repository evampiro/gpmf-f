import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer(
      {Key? key,
      required this.player,
      this.left = true,
      required this.duplicateAlertProvider})
      : super(key: key);
  final Player player;
  final bool left;
  final StateProvider<bool> duplicateAlertProvider;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoState();
}

class _VideoState extends ConsumerState<VideoPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool play = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * 0.5625,
                child: Video(
                  showControls: false,
                  player: widget.player,
                ),
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
                          'Duplicate',
                          style: TextStyle(fontSize: 55, color: Colors.red),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          Container(
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
                    if (play) {
                      _controller.reverse();
                      play = false;
                      widget.player.pause();
                    } else {
                      _controller.forward();
                      play = true;
                      widget.player.play();
                    }
                  },
                  child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause, progress: _controller),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      );
    });
  }
}
