import 'package:extensions/configuration.dart';

void main() {
  var configurationBuilder = ConfigurationBuilder()
    // Adds a memory collection to the configuration system.
    ..addInMemoryCollection(
      <String, String>{
        'Logging:LogLevel:Default': 'Warning',
      }.entries,
    );

  var config = configurationBuilder.build();
  print(config['Logging:LogLevel:Default']);
}
