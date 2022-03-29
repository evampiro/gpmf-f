import 'package:flutter/material.dart';

class DialogPrompt extends StatelessWidget {
  Function onYes;
  String message;
  DialogPrompt({Key? key,required this.onYes,this.message="Are you sure you want to remove the marker?"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              decoration: ShapeDecoration(
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                      20),
                ),
              ),
              child: Padding(
                padding:
                const EdgeInsets.all(
                    12.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      message,
                      textAlign:
                      TextAlign.center,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child:
                          ElevatedButton(
                            onPressed: () async {
                              await onYes();
                              Navigator.pop(
                                  context);
                            },
                            child:
                            Text("Yes"),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child:
                          ElevatedButton(
                              onPressed:
                                  () {
                                Navigator.pop(
                                    context);
                              },
                              style:
                              ButtonStyle(
                                backgroundColor:
                                MaterialStateColor.resolveWith(
                                        (states) =>
                                    Theme.of(context).primaryColor),
                              ),
                              child: Text(
                                  "No")),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
