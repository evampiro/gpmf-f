import 'package:badges/badges.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/utilities/intents.dart';

import '../models/custommarker.dart';

class OutletForm extends StatefulWidget {
  OutletForm({Key? key, required this.customMarker}) : super(key: key);
  final CustomMarker customMarker;

  @override
  State<OutletForm> createState() => _OutletFormState();
}

class _OutletFormState extends State<OutletForm> {
  String? categoryName, sizeName;
  TextEditingController _categoriesName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _Key = GlobalKey<ScaffoldMessengerState>();
  final List<String> categories = [
        'Grocery',
        'Clothing',
        'Hardware',
        'Cosmetics',
        'Pharmacy',
        'Stationary',
      ],
      size = [
        "<1 Shutter",
        "1 Shutter",
        "2 Shutter",
        ">2 Shutter",
      ];
  List list = [
    Colors.red,
    Colors.white,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.blue,
    Colors.black,
    Colors.brown,
    Colors.amber,
    Colors.purpleAccent,
  ];
  late Color selectedColor;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _categoriesName = TextEditingController(
        text: (widget.customMarker.name ?? '').isNotEmpty
            ? widget.customMarker.name
            : '');
    categoryName = widget.customMarker.category;
    sizeName = widget.customMarker.size;
    if (list.contains(widget.customMarker.color)) {
      list.remove(widget.customMarker.color);
      list.insert(0, widget.customMarker.color);
    } else {
      list.insert(0, widget.customMarker.color);
    }
    selectedColor = widget.customMarker.color;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _Key,
      child: WillPopScope(
        onWillPop: () {
          IntentFunctions().focus.requestFocus();

          return Future.value(true);
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Category"),
                        SizedBox(
                          height: 5,
                        ),
                        DropdownSearch<String>(
                          validator: (marker) {
                            RegExp nameValid = RegExp('[a-zA-Z]');
                            if ((marker ?? "").isEmpty) {
                              return 'Category cannot be empty';
                            } else if (!nameValid.hasMatch((marker ?? ""))) {
                              return "Category must contain alphabets only";
                            }
                          },
                          showSearchBox: true,
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          items: categories,
                          // itemAsString: (marker){
                          //   return marker!.category!;
                          // },

                          // popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (value) {
                            // widget.customMarker.category=categoryName;
                            categoryName = value ?? "";
                          },
                          selectedItem: categoryName,
                          showClearButton: true,
                          dropdownSearchDecoration: InputDecoration(
                            // hintText: "Select Categories",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: const Color(0xff6DA7FE),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color(0xff6DA7FE),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.only(left: 12, top: 4),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("Shop Size"),
                        SizedBox(
                          height: 5,
                        ),
                        DropdownSearch<String>(
                          validator: (marker) {
                            RegExp nameValid = RegExp('[a-zA-Z]');
                            if ((marker ?? "").isEmpty) {
                              return 'Size cannot be empty';
                            } else if (!nameValid.hasMatch((marker ?? ""))) {
                              return "Size must contain alphabets only";
                            }
                          },
                          showSearchBox: false,
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          items: size,
                          // itemAsString: (marker){
                          //   return marker!.category!;
                          // },

                          // popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (value) {
                            // widget.customMarker.category=categoryName;
                            sizeName = value ?? "";
                          },
                          selectedItem: sizeName,
                          showClearButton: true,
                          dropdownSearchDecoration: InputDecoration(
                            // hintText: "Select Size",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: const Color(0xff6DA7FE),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color(0xff6DA7FE),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.only(left: 12, top: 4),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("Shop Name"),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          validator: (name) {
                            if (name!.isNotEmpty) {
                              if (name.length <= 3) {
                                return "Name must contain more than 3 letters";
                              }
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: const Color(0xff6DA7FE),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: Color(0xff6DA7FE),
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.only(left: 12, top: 4),
                          ),
                          controller: _categoriesName,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: list
                          .map(
                            (e) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = e;
                                });
                              },
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      padding: EdgeInsets.all(5),
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: e,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Visibility(
                                      visible: e == selectedColor,
                                      child: Container(
                                        height: 16,
                                        width: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Icon(
                                            Icons.done,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.red,
                    child: ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if ((widget.customMarker.category ?? "") ==
                                  categoryName &&
                              (widget.customMarker.size ?? "") == sizeName &&
                              widget.customMarker.name ==
                                  _categoriesName.text) {
                            _Key.currentState?.showSnackBar(
                              const SnackBar(content: Text('No changes made.')),
                            );
                          } else {
                            widget.customMarker
                              ..name = _categoriesName.text
                              ..category = categoryName
                              ..size = sizeName;
                            // _Key.currentState?.showSnackBar(
                            //   const SnackBar(content: Text('Saved')),
                            // );
                            Navigator.pop(context);
                          }
                        }
                        widget.customMarker.color = selectedColor;
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
