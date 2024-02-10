import 'dart:collection';

import 'package:extensions/dependency_injection.dart';

void main() {
  var collection = ServiceCollection();
  collection.addSingleton<String>((services) => '1');
  collection.addSingleton<String>((services) => '2');
  collection.addSingleton<int>((services) => 3);
  collection.addSingleton<int>((services) => 4);
  collection.addSingleton<int>((services) => 5);
  var sp = collection.buildServiceProvider();

  var result = sp.getService<int>();

  print(result);
}
