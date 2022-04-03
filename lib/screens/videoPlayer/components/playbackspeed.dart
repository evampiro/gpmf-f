import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';

class PlayBackSpeed extends StatefulWidget {
  PlayBackSpeed({
    Key? key,
    required this.player,
  }) : super(key: key);
  final Player player;
  @override
  State<PlayBackSpeed> createState() => _PlayBackSpeedState();
}

class _PlayBackSpeedState extends State<PlayBackSpeed> {
  final List<double> data = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

  int selected = 3;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selected =
        data.indexWhere((element) => element == widget.player.general.rate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Playback Speed"),
        const SizedBox(
          height: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: data
              .map(
                (e) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selected = data.indexOf(e);
                        widget.player.setRate(e);
                      });
                      //Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        data[selected] == e
                            ? const SizedBox(
                                width: 10,
                                child: Icon(
                                  Icons.done,
                                ),
                              )
                            : const SizedBox(
                                width: 10,
                              ),
                        const SizedBox(
                          width: 30,
                        ),
                        Text(
                          e == 1 ? 'Normal' : e.toString(),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
