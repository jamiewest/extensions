import 'package:extensions/dependency_injection.dart';

void main() {
  var collection = ServiceCollection()
    ..addSingleton<String>((services) => '1')
    ..addSingleton<String>((services) => '2')
    ..addSingleton<int>((services) => 3)
    ..addSingleton<int>((services) => 4)
    ..addSingleton<int>((services) => 5);
  var sp = collection.buildServiceProvider();

  var result = sp.getService<int>();

  print(result);
}
