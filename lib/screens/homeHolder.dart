import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/AIv2.dart';
import 'package:gpmf/screens/animatedindexedstack.dart';
import 'package:gpmf/screens/home.dart';
import 'package:process_run/shell.dart';

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
            Expanded(child: TabScreen())
          ],
        )),
      ),
    );
  }
}

class TabItem {
  TabItem({required this.title, required this.icon, this.id = 0});
  String title;
  IconData icon;
  int id;
}

class TabScreen extends StatefulWidget {
  TabScreen({Key? key}) : super(key: key);

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  int pageIndex = 0;

  List<TabItem> tabs = [
    TabItem(title: 'Video Player', icon: Icons.fmd_good, id: 0),
    TabItem(title: 'Screenshot', icon: Icons.picture_in_picture, id: 1),
    TabItem(title: 'Duplicate Elimination', icon: Icons.copy, id: 2),
    TabItem(title: 'Compression', icon: Icons.video_label, id: 3),
    TabItem(title: 'Telemetry Extracter', icon: Icons.account_tree, id: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 45,
          child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final items = tabs.removeAt(oldIndex);
                  tabs.insert(newIndex, items);
                });
              },
              buildDefaultDragHandles: false,
              anchor: 0,
              children: [
                for (int i = 0; i < tabs.length; i++)
                  tab(
                    item: tabs[i],
                    index: i,
                    onTap: () {},
                  )
              ]),
        ),
        Expanded(
            child: IndexedStack(
          index: pageIndex,
          children: [
            Home(
              videoPlayer: true,
            ),
            Home(
              videoPlayer: false,
            ),
            AIScreen2(),
            Container(),
            Container()
          ],
        ))
      ],
    );
  }

  Widget tab(
      {required TabItem item, required Function onTap, required int index}) {
    return GestureDetector(
      key: Key(item.id.toString()),
      onTap: () {
        setState(() {
          pageIndex = item.id;
        });

        onTap();
      },
      child: ReorderableDragStartListener(
        index: index,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 80,
          ),
          height: 35,
          color: item.id == pageIndex
              ? Colors.grey
              : Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
              ),
              Icon(
                item.icon,
                size: 12,
              ),
              const SizedBox(
                width: 10,
              ),
              Text('${item.title}'),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
