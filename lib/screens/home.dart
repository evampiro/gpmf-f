import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  final bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: DropTarget(
      onDragDone: (detail) {
        print(detail);
        // detail.files.
      },
      onDragEntered: (detail) {
        print(detail);
      },
      onDragExited: (detail) {
        print(detail);
      },
      child: Container(
        height: 200,
        width: 200,
        color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.blueGrey,
        child: const Center(child: Text("Drop here")),
      ),
    ));
  }
}
