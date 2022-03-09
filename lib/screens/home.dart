import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import 'package:gpmf/screens/map.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlng/latlng.dart';
import 'package:map/map.dart';

final DataListProvider = StateProvider<List<GeoFile>>((ref) {
  return [];
});

class GeoFile {
  GeoFile({required this.file, required this.geoData});
  File file;
  List<GeoData> geoData;
}

class GeoData {
  GeoData({required this.lat, required this.lon, required this.time});
  double lon, lat;
  DateTime time;
}

class Home extends ConsumerWidget {
  Home({Key? key}) : super(key: key);
  final refreshProvider = StateProvider<int?>((ref) {
    return 0;
  });
  final bool _dragging = false;
  // final MapController _controller = MapController(location: LatLng(30, 30));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(DataListProvider.state).state;
    final refresh = ref.watch(DataListProvider.state).state;
    return Scaffold(
        body: DropTarget(
      onDragDone: (detail) async {
        ref.read(DataListProvider.state).state = [];
        List<GeoFile> geoData = [];
        for (final file in detail.files) {
          debugPrint('  ${file.path} ${file.name}'
              '  ${await file.lastModified()}'
              '  ${await file.length()}'
              '  ${file.mimeType}');

          try {
            var dat = await file.readAsString();
            var json = jsonDecode(dat);

            List<GeoData> data = [];

            for (int i = 0; i < json.length; i++) {
              data.add(GeoData(
                  lat: json[i]["value"][0],
                  lon: json[i]["value"][1],
                  time: DateTime.parse(json[i]["date"].toString())));
            }
            geoData.add(GeoFile(file: File(file.path), geoData: data));
          } catch (e, s) {
            print(e);
          }
        }
        ref.read(DataListProvider.state).state = geoData.toList();
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
          Visibility(
            visible: false,
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
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {},
                            title: Text(list[index].file.path),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.red,
                            ),
                            subtitle: Slider(
                              value: 128,
                              onChanged: (v) {},
                              min: 0,
                              max: 128,
                              label: '128',
                            ),
                            // trailing: Text("${list?[index].time}"),
                          );
                        }),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                        color: Colors.grey,
                        child: list.isNotEmpty
                            ? MapScreen(
                                mapController: MapController(
                                  zoom: 17,
                                  location: LatLng(list[0].geoData[0].lat,
                                      list[0].geoData[0].lon),
                                ),
                                markers: getMarkers(list[0].geoData),

                                // markers: [
                                //   LatLng(list[0].lat!, list[0].lon!),
                                //   LatLng(list[(list.length - 1) ~/ 2].lat!,
                                //       list[(list.length - 1) ~/ 2].lon!),
                                //   LatLng(list[list.length - 1].lat!,
                                //       list[list.length - 1].lon!)
                                // ],
                                // markers: list
                                //     .map((e) => LatLng(e.lat!, e.lon!))
                                //     .toList(),
                              )
                            : const Center(
                                child: Text('Load Data to visualize'),
                              )),
                  )
                ],
              ))
        ],
      ),
    ));
  }

  List<LatLng> getMarkers(List<GeoData> data) {
    List<LatLng> temp = [];
    temp = data.map((e) => LatLng(e.lat, e.lon)).toList();

    var c = temp.toList();
    for (var element in temp) {
      c.removeWhere((e) =>
          element.latitude == e.latitude || element.longitude == e.longitude);
      c.add(element);
    }
    temp.clear();
    for (int i = 0; i < c.length; i += 128) {
      temp.add(LatLng(data[i].lat, data[i].lon));
    }
    // print(temp.length);
    return temp;
  }
}
