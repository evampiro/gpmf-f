import 'dart:math';

bool checkDifference(int a, int b, int difference) {
  if (max(a, b) - min(a, b) == difference) return true;
  return false;
}

executeNew() {
  List<int> a = [
    8,
    11,
    12,
    13,
    14,
    16,
    98,
  ];

  List removeAtIndexes = [];
  int i = 1;
  int constantDifference = 1;
  bool isIntoCircle = false;
  int? lastNumber;
  for (int j = i; j < a.length; j++) {
    if (checkDifference(a[i], a[j], constantDifference)) {
      if (lastNumber != null) {
        constantDifference += (a[j] - lastNumber);
      } else {
        constantDifference += (a[j] - a[i]);
      }
      lastNumber = a[j];
      removeAtIndexes.add(j);
    }
  }

  for (int i = removeAtIndexes.length - 1; i > -1; i--) {
    a.removeAt(removeAtIndexes[i]);
  }
  print(a);
}
