import 'package:extensions/hosting.dart';
import 'package:test/test.dart';

void main() {
  group('HostBuilderTests', () {
    test('DefaultConfigIsMutable', () {
      var host = HostBuilder().build();

      var config = host.services.getRequiredService<Configuration>();
      config['key1'] = 'value';
      expect(config['key1'], equals('value'));
    });
  });
}
