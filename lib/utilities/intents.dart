import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpaceIntent extends Intent {}

final spaceBarKeySet = LogicalKeySet(
  LogicalKeyboardKey.space, // Replace with control on Windows
);

class ArrowLeftIntent extends Intent {}

final arrowLeftKeySet = LogicalKeySet(
  LogicalKeyboardKey.arrowLeft, // Replace with control on Windows
);

class ControlTabIntent extends Intent {}

final controlTabKeySet = LogicalKeySet(
  LogicalKeyboardKey.control,
  LogicalKeyboardKey.tab,
  // Replace with control on Windows
);

class SKeyIntent extends Intent {}

final sKeySet = LogicalKeySet(
  LogicalKeyboardKey.keyS,

  // Replace with control on Windows
);

class EscKeyIntent extends Intent {}

final escKeySet = LogicalKeySet(
  LogicalKeyboardKey.escape,

  // Replace with control on Windows
);

class IntentFunctions {
  static final IntentFunctions _instance = IntentFunctions._internal(
      onSpace: () {}, onArrowLeft: () {}, onControlTab: () {}, onSKey: () {});

  factory IntentFunctions() => _instance;

  IntentFunctions._internal(
      {required this.onSpace,
      required this.onArrowLeft,
      required this.onControlTab,
      required this.onSKey});

  Function onSpace, onArrowLeft, onControlTab, onSKey;
}
