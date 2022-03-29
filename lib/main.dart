import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:gpmf/screens/videoPlayer/homeHolder.dart';
import 'package:gpmf/utilities/intents.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DartVLC.initialize();
  doWhenWindowReady(() {
    final win = appWindow;
    final initialSize = Size(600, 450);
    win.minSize = initialSize;
    // win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Custom window with Flutter";

    win.startDragging();
    win.show();
    win.maximize();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Demo',
          themeMode: ThemeMode.system,
          darkTheme: ThemeData(brightness: Brightness.dark),
          theme: ThemeData(
            brightness: Brightness.light,
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: FocusableActionDetector(
              focusNode: IntentFunctions().focus,
              autofocus: true,
              shortcuts: {
                spaceBarKeySet: SpaceIntent(),
                arrowLeftKeySet: ArrowLeftIntent(),
                controlTabKeySet: ControlTabIntent(),
                sKeySet: SKeyIntent(),
              },
              actions: {
                SpaceIntent: CallbackAction(
                  onInvoke: (intent) {
                    if (IntentFunctions().isSpaceActive) {
                      return IntentFunctions().onSpace();
                    }
                  },
                ),
                ArrowLeftIntent: CallbackAction(onInvoke: (intent) {
                  return IntentFunctions().onArrowLeft();
                }),
                ControlTabIntent: CallbackAction(onInvoke: (intent) {
                  return IntentFunctions().onControlTab();
                }),
                SKeyIntent: CallbackAction(onInvoke: (intent) {
                  return IntentFunctions().onSKey();
                }),
              },
              child: const HomeHolder())),
    );
  }
}
