import 'dart:convert';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

final DataListProvider = StateProvider<List<GeoData>?>((ref) {
  return;
});

class GeoData {
  GeoData({this.lat, this.lon, this.time});
  double? lon, lat;
  DateTime? time;
}

class Home extends ConsumerWidget {
  Home({Key? key}) : super(key: key);
  final refreshProvider = StateProvider<int?>((ref) {
    return 0;
  });
  final bool _dragging = false;
  final MapController _controller = MapController(location: LatLng(30, 30));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(DataListProvider.state).state;
    final refresh = ref.watch(DataListProvider.state).state;
    return Scaffold(
        body: DropTarget(
      onDragDone: (detail) async {
        for (final file in detail.files) {
          debugPrint('  ${file.path} ${file.name}'
              '  ${await file.lastModified()}'
              '  ${await file.length()}'
              '  ${file.mimeType}');

          try {
            var dat = await file.readAsString();
            var json = jsonDecode(dat);
            ref.read(DataListProvider.state).state = [];

            List<GeoData> data = [];

            for (int i = 0; i < json.length; i++) {
              data.add(GeoData(
                  lat: json[i]["value"][0],
                  lon: json[i]["value"][1],
                  time: DateTime.parse(json[i]["date"].toString())));
            }
            ref.read(DataListProvider.state).state = data.toList();
          } catch (e, s) {
            print(e);
          }
        }
        // detail.files.
      },
      onDragEntered: (detail) {
        print(detail);
      },
      onDragExited: (detail) {
        print(detail);
      },
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.blueGrey,
              child: const Center(child: Text("Drop here")),
            ),
          ),
          Expanded(
              flex: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                        itemCount: list?.length ?? 0,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("${list?[index].lat}"),
                            subtitle: Text("${list?[index].lon}"),
                            trailing: Text("${list?[index].time}"),
                          );
                        }),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.grey,
                      child: list != null
                          ? MapScreen(
                              mapController: MapController(
                                location: LatLng(list[0].lat!, list[0].lon!),
                              ),
                              // markers: [],
                              markers: list
                                  .map((e) => LatLng(e.lat!, e.lon!))
                                  .toList(),
                            )
                          : const Center(
                              child: Text('Load Data to visualize'),
                            ),
                    ),
                  )
                ],
              ))
        ],
      ),
    ));
  }
}
