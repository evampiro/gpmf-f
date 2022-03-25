import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../models/custommarker.dart';


class OutletForm extends StatefulWidget {
  OutletForm({Key? key, required this.customMarker}) : super(key: key);
  final CustomMarker customMarker;

  @override
  State<OutletForm> createState() => _OutletFormState();
}

class _OutletFormState extends State<OutletForm> {

  String? categoryName;
  TextEditingController _categoriesName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _Key = GlobalKey<ScaffoldMessengerState>();
  final List<String> listOfValue = [
    'kathmandu',
    'pokhara',
    'patan',
    'lumbini',
    'janakpur'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _categoriesName = TextEditingController(
        text: (widget.customMarker.name??'').isNotEmpty
            ? widget.customMarker.name
            : '');
    categoryName=widget.customMarker.category;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScaffoldMessenger(
        key: _Key,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      DropdownSearch<String>(
                        validator: (marker) {
                          RegExp nameValid = RegExp('[a-zA-Z]');
                          if ((marker??"").isEmpty) {
                            return 'Name cannot be empty';
                          }
                          else if (!nameValid.hasMatch((marker??""))) {
                            return "Name must contain alphabets only";
                          }
                        },
                        showSearchBox: true,
                        mode: Mode.MENU,
                        showSelectedItems: true,
                        items: listOfValue,
                        // itemAsString: (marker){
                        //   return marker!.category!;
                        // },

                        // popupItemDisabled: (String s) => s.startsWith('I'),
                        onChanged: (value) {
                          // widget.customMarker.category=categoryName;
                          categoryName = value??"";
                        },
                        selectedItem: categoryName,
                        showClearButton: true,
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Select Categories",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Color(0xff6DA7FE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Color(0xff6DA7FE),
                            ),
                          ),
                          contentPadding: EdgeInsets.only(left: 12, top: 4),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        validator: (name) {
                          RegExp nameValid = RegExp('[a-zA-Z]');
                          if (name!.isEmpty) {
                            return 'Name cannot not be empty';
                          } else if (!nameValid.hasMatch(name)) {
                            return "Name must contain alphabets only";
                          } else if(name.length<=3){
                            return "Name must contain more than 3 letters";
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Color(0xff6DA7FE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Color(0xff6DA7FE),
                            ),
                          ),
                          contentPadding: EdgeInsets.only(left: 12, top: 4),
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: "Enter Name",
                        ),
                        controller: _categoriesName,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12,),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if ((widget.customMarker.category??"") == categoryName && widget.customMarker.name==_categoriesName.text){
                        _Key.currentState?.showSnackBar(
                          const SnackBar(content: Text('No changes made.')),
                        );
                      }
                      else{
                        widget.customMarker
                          ..name = _categoriesName.text
                          ..category = categoryName;
                        _Key.currentState?.showSnackBar(
                          const SnackBar(content: Text('Processing Data.')),
                        );
                      }
                    }
                  },
                  child: Text("Button"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

