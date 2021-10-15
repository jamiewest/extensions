import 'package:extensions/src/configuration/configuration_provider.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';
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
  Tuple2<ConfigurationProvider, Function> loadThroughProvider(
    TestSection testConfig,
  ) =>
      ConfigurationProviderTestBase.loadUsingMemoryProvider(testConfig);
}
