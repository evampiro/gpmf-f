import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/home.dart';

final buttonColors = WindowButtonColors(
    iconNormal: Colors.white,
    // mouseOver: const Color(0xFFF6A00C),
    mouseOver: Colors.grey,
    mouseDown: const Color(0xFF805306),
    iconMouseOver: Colors.white,
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: Colors.white,
    iconMouseOver: Colors.white);

class HomeHolder extends StatefulWidget {
  const HomeHolder({Key? key}) : super(key: key);

  @override
  State<HomeHolder> createState() => _HomeHolderState();
}

class _HomeHolderState extends State<HomeHolder> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: Colors.red.withOpacity(0.1),
        child: Container(
            child: Column(
          children: [
            WindowTitleBarBox(
                child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color:
                              Colors.grey[800]!))), //color: Colors.grey[900],
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.gps_fixed,
                          size: 15,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          "Gpmf pro",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      MoveWindow(),
                    ],
                  )),
                  Row(
                    children: [
                      MinimizeWindowButton(colors: buttonColors),
                      MaximizeWindowButton(colors: buttonColors),
                      CloseWindowButton(colors: closeButtonColors),
                    ],
                  )
                ],
              ),
            )),
            Expanded(child: Home())
          ],
        )),
      ),
    );
  }
}
