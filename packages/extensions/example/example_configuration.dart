import 'package:extensions/configuration.dart';

void main() {
  // var configurationBuilder = ConfigurationBuilder()
  //   // Adds a memory collection to the configuration system.
  //   ..addInMemoryCollection(
  //     <String, String>{
  //       'Logging:LogLevel:Default': 'Warning',
  //     }.entries,
  //   );

  // var config = configurationBuilder.build();
  // print(config['Logging:LogLevel:Default']);

  const jsonString =
      '{"text": "foo", "value": 1, "status": false, "extra": null}';

  const jsonArray = '''
  [{"text": "foo", "value": 1, "status": true},
   {"text": "bar", "value": 2, "status": false}]
''';

  var builder = ConfigurationBuilder()..addJson(jsonArray);
  var config = builder.build();
  print(config.getDebugView());
}
