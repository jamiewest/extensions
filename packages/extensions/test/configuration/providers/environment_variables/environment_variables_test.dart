import 'dart:collection';

import 'package:extensions/src/configuration/providers/environment_variables/environment_variables_configuration_provider.dart';
import 'package:test/test.dart';
import '../../common/configuration_provider_extensions.dart';

void main() {
  group('EnvironmentVariablesTest', () {
    test('LoadKeyValuePairsFromEnvironmentDictionary', () {
      var dict = LinkedHashMap.from({
        'DefaultConnection:ConnectionString': 'TestConnectionString',
        'DefaultConnection:Provider': 'SqlClient',
        'Inventory:ConnectionString': 'AnotherTestConnectionString',
        'Inventory:Provider': 'MySql',
      });

      var envConfigSrc = EnvironmentVariablesConfigurationProvider(null)
        ..loadInternal(dict);

      expect(envConfigSrc.get('defaultconnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(
          envConfigSrc.get('DEFAULTCONNECTION:PROVIDER'), equals('SqlClient'));
      expect(envConfigSrc.get('Inventory:CONNECTIONSTRING'),
          equals('AnotherTestConnectionString'));
      expect(envConfigSrc.get('Inventory:Provider'), equals('MySql'));
    });
  });
}
