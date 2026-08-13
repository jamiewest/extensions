import 'package:extensions/configuration.dart';

/// Shows how to seed an in-memory configuration source and read values.
///
/// Run this file to print `Logging:LogLevel:Default` from configuration.
void main() {
  print('=== Configuration Example ===');

  // #region in_memory_configuration
  final configurationBuilder = ConfigurationBuilder()
    // In-memory data is a simple way to compose config for tests or demos.
    ..addInMemoryCollection(
      <String, String>{'Logging:LogLevel:Default': 'Warning'}.entries,
    );

  final configuration = configurationBuilder.build();
  // #endregion

  print('--- Read Value ---');
  print(
    'Logging:LogLevel:Default = '
    '${configuration['Logging:LogLevel:Default']}',
  );
}
