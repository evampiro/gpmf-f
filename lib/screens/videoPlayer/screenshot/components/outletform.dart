import 'package:dropdown_search/dropdown_search.dart';
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
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        DropdownSearch<String>(
                          validator: (marker) {
                            RegExp nameValid = RegExp('[a-zA-Z]');
                            if ((marker ?? "").isEmpty) {
                              return 'Name cannot be empty';
                            } else if (!nameValid.hasMatch((marker ?? ""))) {
                              return "Name must contain alphabets only";
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
                            hintText: "Select Categories",
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
                            hintText: "Select Size",
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
                            hintStyle: const TextStyle(color: Colors.grey),
                            hintText: "Enter Name",
                          ),
                          controller: _categoriesName,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
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
                            _Key.currentState?.showSnackBar(
                              const SnackBar(content: Text('Saved')),
                            );
                          }
                        }
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
