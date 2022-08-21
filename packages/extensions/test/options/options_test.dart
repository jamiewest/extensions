import 'package:extensions/src/dependency_injection/service_collection.dart';
import 'package:extensions/src/dependency_injection/service_collection_container_builder_extensions.dart';
import 'package:extensions/src/dependency_injection/service_collection_service_extensions.dart';
import 'package:extensions/src/dependency_injection/service_provider_service_extensions.dart';
import 'package:extensions/src/options/options.dart';
import 'package:extensions/src/options/options_factory.dart';
import 'package:extensions/src/options/options_service_collection_extensions.dart';
import 'package:test/test.dart';

import 'fake_options.dart';
import 'fake_options_factory.dart';

void main() {
  group('OptionsTest', () {
    test('UsesFactory', () {
      var services = ServiceCollection()
          .addSingleton<OptionsFactory<FakeOptions>>(
            (sp) => FakeOptionsFactory(),
          )
          .configure<FakeOptions>(
            FakeOptions.new,
            (options) => options.message = 'Ignored',
          )
          .buildServiceProvider();

      var snap = services.getRequiredService<Options<FakeOptions>>();
      expect(snap.value, equals(FakeOptionsFactory.options));
    });
  });
}
