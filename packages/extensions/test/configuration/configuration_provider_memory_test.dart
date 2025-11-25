import 'package:extensions/src/configuration/configuration_provider.dart';
import 'package:extensions/src/primitives/void_callback.dart';
import 'package:test/test.dart';
import 'configuration_provider_test_base.dart';

void main() {
  group('ConfigurationProviderMemoryTest', () {
    test('NullValuesAreIncludedInTheConfig', () {
      ConfigurationProviderMemoryTest().test();
    });
  });
}

class ConfigurationProviderMemoryTest extends ConfigurationProviderTestBase {
  void test() {
    assertConfig(
      buildConfigRoot([loadThroughProvider(TestSection.nullsTestConfig)]),
      expectNulls: true,
    );
  }

  @override
  (ConfigurationProvider, VoidCallback) loadThroughProvider(
    TestSection testConfig,
  ) =>
      ConfigurationProviderTestBase.loadUsingMemoryProvider(testConfig);
}
