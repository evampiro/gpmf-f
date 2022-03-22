import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VideoPlayer extends ConsumerStatefulWidget {
  const VideoPlayer(
      {Key? key,
      required this.player,
      this.left = true,
      required this.duplicateAlertProvider,
      required this.modeProvider})
      : super(key: key);
  final Player player;
  final bool left;
  final StateProvider<bool> duplicateAlertProvider, modeProvider;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoState();
}

class _VideoState extends ConsumerState<VideoPlayer>
    with TickerProviderStateMixin {
  late AnimationController _playController, _modeController;
  bool play = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _modeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

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
      final mode = ref.watch(widget.modeProvider.state).state;
      return Column(
        children: [
          Stack(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight - 45,
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
                          'Potential Duplicate',
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
                      _playController.reverse();
                      play = false;
                      widget.player.pause();
                    } else {
                      _playController.forward();
                      play = true;
                      widget.player.play();
                    }
                  },
                  child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _playController),
                ),
                GestureDetector(
                  onTap: () {
                    if (mode) {
                      _modeController.reverse();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        ref.read(widget.modeProvider.state).state = false;
                      });
                    } else {
                      _modeController.forward();
                      //  play = true;
                      Future.delayed(const Duration(milliseconds: 300), () {
                        ref.read(widget.modeProvider.state).state = true;
                      });
                    }
                  },
                  child: AnimatedIcon(
                      icon: AnimatedIcons.arrow_menu,
                      progress: _modeController),
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
