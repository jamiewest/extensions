import 'package:extensions/src/options/options_factory.dart';

import 'fake_options.dart';

class FakeOptionsFactory implements OptionsFactory<FakeOptions> {
  static FakeOptions options = FakeOptions();

  @override
  FakeOptions create(String name) => options;
}
