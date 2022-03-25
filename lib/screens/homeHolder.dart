import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/AIv2.dart';
import 'package:gpmf/screens/home.dart';
import 'package:gpmf/screens/intents.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

class HomeHolder extends ConsumerStatefulWidget {
  const HomeHolder({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeHolder> createState() => _HomeHolderState();
}

final currentPageIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class _HomeHolderState extends ConsumerState<HomeHolder>
    with TickerProviderStateMixin {
  List<TabItem> tabs = [
    TabItem(title: 'Video Player', icon: Icons.fmd_good, id: 0),
    TabItem(title: 'Screenshot', icon: Icons.picture_in_picture, id: 1),
    TabItem(title: 'Duplicate Elimination', icon: Icons.copy, id: 2),
    TabItem(title: 'Compression', icon: Icons.video_label, id: 3),
    TabItem(title: 'Telemetry Extracter', icon: Icons.account_tree, id: 4),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    IntentFunctions().onControlTab = () {
      int currentindex = ref.read(currentPageIndexProvider.state).state;
      if (currentindex < tabs.length - 1) {
        currentindex++;
      } else if (currentindex == tabs.length - 1) {
        currentindex = 0;
      }
      ref.read(currentPageIndexProvider.state).state = currentindex;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: Colors.red.withOpacity(0.1),
        child: Column(
          children: [
            WindowTitleBarBox(
                child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.grey[800]!
                              .withOpacity(0)))), //color: Colors.grey[900],
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
                    child: Consumer(builder: (context, ref, c) {
                      return SizedBox(
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
                      );
                    }),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Gpmf pro",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        MoveWindow(),
                      ],
                    ),
                  ),
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
            Expanded(child: Consumer(builder: (context, ref, c) {
              final index = ref.watch(currentPageIndexProvider.state).state;
              return IndexedStack(
                index: index,
                children: [
                  const Home(
                    videoPlayer: true,
                  ),
                  const Home(
                    videoPlayer: false,
                  ),
                  const AIScreen2(),
                  Container(),
                  Container()
                ],
              );
            }))
          ],
        ),
      ),
    );
  }

  Widget tab({
    required TabItem item,
    required Function onTap,
    required int index,
  }) {
    return Consumer(
        key: Key(item.id.toString()),
        builder: (context, ref, c) {
          final pageIndex = ref.watch(currentPageIndexProvider.state).state;
          return Tooltip(
            waitDuration: const Duration(milliseconds: 800),
            message: item.title,
            child: GestureDetector(
              onTap: () {
                ref.read(currentPageIndexProvider.state).state = item.id;

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
                        width: 10,
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
            ),
          );
        });
  }
}

class TabItem {
  TabItem({required this.title, required this.icon, this.id = 0});
  String title;
  IconData icon;
  int id;
}
