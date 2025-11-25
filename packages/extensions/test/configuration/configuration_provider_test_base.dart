import 'package:extensions/configuration.dart';
import 'package:extensions/src/primitives/void_callback.dart';
import 'package:test/test.dart';

abstract class ConfigurationProviderTestBase {
  void loadFromSingleProvider() {
    var configRoot =
        buildConfigRoot([loadThroughProvider(TestSection.testConfig)]);

    assertConfig(configRoot);
  }

  void hasDebugView() {
//     var configRoot =
//         buildConfigRoot([loadThroughProvider(TestSection.testConfig)]);
//     var providerTag = configRoot.providers.first.toString();
//     var expected = '''
// Key1=Value1 ({providerTag})
// Section1:
//   Key2=Value12 ({providerTag})
//   Section2:
//     Key3=Value123 ({providerTag})
//     Key3a:
//       0=ArrayValue0 ({providerTag})
//       1=ArrayValue1 ({providerTag})
//       2=ArrayValue2 ({providerTag})
// Section3:
//   Section4:
//     Key4=Value344 ({providerTag})

//     ''';
  }

  void assertDebugView(ConfigurationRoot config, String expected) {
    String removeLineEnds(String source) =>
        source.replaceAll('\n', '').replaceAll('\r', '');

    var actual = config.getDebugView();

    expect(removeLineEnds(actual), equals(removeLineEnds(expected)));
  }

  void assertConfig(
    ConfigurationRoot config, {
    bool expectNulls = false,
    // Turning this off to match source.
    // ignore: avoid_init_to_null
    String? nullValue = null,
  }) {
    var value1 = expectNulls ? nullValue : 'Value1';
    var value12 = expectNulls ? nullValue : 'Value12';
    var value123 = expectNulls ? nullValue : 'Value123';
    var arrayvalue0 = expectNulls ? nullValue : 'ArrayValue0';
    var arrayvalue1 = expectNulls ? nullValue : 'ArrayValue1';
    var arrayvalue2 = expectNulls ? nullValue : 'ArrayValue2';
    var value344 = expectNulls ? nullValue : 'Value344';

    expect(config['Key1'], equals(value1));
    expect(config['Section1:Key2'], equals(value12));
    expect(config['Section1:Section2:Key3'], equals(value123));
    expect(config['Section1:Section2:Key3a:0'], equals(arrayvalue0));
    expect(config['Section1:Section2:Key3a:1'], equals(arrayvalue1));
    expect(config['Section1:Section2:Key3a:2'], equals(arrayvalue2));
    expect(config['Section3:Section4:Key4'], equals(value344));

    var section1 = config.getSection('Section1');
    expect(section1['Key2'], equals(value12));
    expect(section1['Section2:Key3'], equals(value123));
    expect(section1['Section2:Key3a:0'], equals(arrayvalue0));
    expect(section1['Section2:Key3a:1'], equals(arrayvalue1));
    expect(section1['Section2:Key3a:2'], equals(arrayvalue2));
    expect(section1.path, equals('Section1'));
    expect(section1.value, isNull);

    var section2 = config.getSection('Section1:Section2');
    expect(section2['Key3'], equals(value123));
    expect(section2['Key3a:0'], equals(arrayvalue0));
    expect(section2['Key3a:1'], equals(arrayvalue1));
    expect(section2['Key3a:2'], equals(arrayvalue2));
    expect(section2.path, equals('Section1:Section2'));
    expect(section2.value, isNull);

    section2 = section1.getSection('Section2');
    expect(section2['Key3'], equals(value123));
    expect(section2['Key3a:0'], equals(arrayvalue0));
    expect(section2['Key3a:1'], equals(arrayvalue1));
    expect(section2['Key3a:2'], equals(arrayvalue2));
    expect(section2.path, equals('Section1:Section2'));
    expect(section2.value, isNull);

    var section3a = section2.getSection('Key3a');
    expect(section3a['0'], equals(arrayvalue0));
    expect(section3a['1'], equals(arrayvalue1));
    expect(section3a['2'], equals(arrayvalue2));
    expect(section3a.path, equals('Section1:Section2:Key3a'));
    expect(section3a.value, isNull);

    var section3 = config.getSection('Section3');
    expect(section3.path, equals('Section3'));
    expect(section3.value, isNull);

    var section4 = config.getSection('Section3:Section4');
    expect(section4['Key4'], equals(value344));
    expect(section4.path, equals('Section3:Section4'));
    expect(section4.value, isNull);

    section4 = config.getSection('Section3').getSection('Section4');
    expect(section4['Key4'], equals(value344));
    expect(section4.path, equals('Section3:Section4'));
    expect(section4.value, isNull);

    var sections = config.getChildren().toList();

    expect(sections.length, equals(3));

    expect(sections[0].key, equals('Key1'));
    expect(sections[0].path, equals('Key1'));
    expect(sections[0].value, equals(value1));

    expect(sections[1].key, equals('Section1'));
    expect(sections[1].path, equals('Section1'));
    expect(sections[1].value, isNull);

    expect(sections[2].key, equals('Section3'));
    expect(sections[2].path, equals('Section3'));
    expect(sections[2].value, isNull);

    sections = section1.getChildren().toList();

    expect(sections.length, equals(2));

    expect(sections[0].key, equals('Key2'));
    expect(sections[0].path, equals('Section1:Key2'));
    expect(sections[0].value, equals(value12));

    expect(sections[1].key, equals('Section2'));
    expect(sections[1].path, equals('Section1:Section2'));
    expect(sections[1].value, isNull);

    sections = section2.getChildren().toList();

    expect(sections.length, equals(2));

    expect(sections[0].key, equals('Key3'));
    expect(sections[0].path, equals('Section1:Section2:Key3'));
    expect(sections[0].value, equals(value123));

    expect(sections[1].key, equals('Key3a'));
    expect(sections[1].path, equals('Section1:Section2:Key3a'));
    expect(sections[1].value, isNull);

    sections = section3a.getChildren().toList();

    expect(sections.length, equals(3));

    expect(sections[0].key, equals('0'));
    expect(sections[0].path, equals('Section1:Section2:Key3a:0'));
    expect(sections[0].value, equals(arrayvalue0));

    expect(sections[1].key, equals('1'));
    expect(sections[1].path, equals('Section1:Section2:Key3a:1'));
    expect(sections[1].value, equals(arrayvalue1));

    expect(sections[2].key, equals('2'));
    expect(sections[2].path, equals('Section1:Section2:Key3a:2'));
    expect(sections[2].value, equals(arrayvalue2));

    sections = section3.getChildren().toList();

    expect(sections.length, equals(1));

    expect(sections[0].key, equals('Section4'));
    expect(sections[0].path, equals('Section3:Section4'));
    expect(sections[0].value, isNull);

    sections = section4.getChildren().toList();

    expect(sections.length, equals(1));

    expect(sections[0].key, equals('Key4'));
    expect(sections[0].path, equals('Section3:Section4:Key4'));
    expect(sections[0].value, equals(value344));
  }

  (ConfigurationProvider, VoidCallback) loadThroughProvider(
    TestSection testConfig,
  );

  static (ConfigurationProvider, VoidCallback) loadUsingMemoryProvider(
      TestSection testConfig) {
    var values = <MapEntry<String, String?>>[];
    sectionToValues(testConfig, '', values);

    return (
      MemoryConfigurationProvider(MemoryConfigurationSource(values)),
      () {}
    );
  }

  ConfigurationRoot buildConfigRoot(
    List<(ConfigurationProvider, VoidCallback)> providers,
  ) {
    var root = ConfigurationRoot(providers.map((e) => e.$1).toList());

    for (var initializer in providers.map((e) => e.$2)) {
      initializer();
    }

    return root;
  }

  static void sectionToValues(
    TestSection section,
    String sectionName,
    List<MapEntry<String, String?>> values,
  ) {
    for (var tuple in section.values!
        .expand((e) => e.$2.expand(e.$1))
        .map((e) => (e.$1, e.$2))) {
      values.add(MapEntry<String, String?>(
        '$sectionName${tuple.$1}',
        tuple.$2 == null ? null : tuple.$2 as String,
      ));
    }

    for (var tuple in section.sections!) {
      sectionToValues(tuple.$2, '$sectionName${tuple.$1}:', values);
    }
  }
}

class TestSection {
  TestSection({
    this.values = const <(String, TestKeyValue)>[],
    this.sections = const <(String, TestSection)>[],
  });

  Iterable<(String, TestKeyValue)>? values;
  Iterable<(String, TestSection)>? sections;

  static TestSection get nullsTestConfig => TestSection()
    ..values = [
      ('Key1', TestKeyValue.value(null)),
    ]
    ..sections = [
      (
        'Section1',
        TestSection()
          ..values = [
            ('Key2', TestKeyValue.value(null)),
          ]
          ..sections = [
            (
              'Section2',
              TestSection()
                ..values = [
                  ('Key3', TestKeyValue.value(null)),
                  ('Key3a', TestKeyValue.values(<String?>[null, null, null])),
                ]
            )
          ]
      ),
      (
        'Section3',
        TestSection()
          ..sections = [
            (
              'Section4',
              TestSection()
                ..values = [
                  ('Key4', TestKeyValue.value(null)),
                ]
            )
          ]
      )
    ];

  static TestSection get testConfig => TestSection()
    ..values = [
      ('Key1', TestKeyValue.value('Value1')),
    ]
    ..sections = [
      (
        'Section1',
        TestSection()
          ..values = [
            ('Key2', TestKeyValue.value('Value12')),
          ]
          ..sections = [
            (
              'Section2',
              TestSection()
                ..values = [
                  ('Key3', TestKeyValue.value('Value123')),
                  (
                    'Key3a',
                    TestKeyValue.values(
                        ['ArrayValue0', 'ArrayValue1', 'ArrayValue2'])
                  ),
                ]
                ..sections = [],
            )
          ]
      ),
      (
        'Section3',
        TestSection()
          ..sections = [
            (
              'Section4',
              TestSection()..values = [('Key4', TestKeyValue.value('Value344'))]
            )
          ]
      )
    ];
}

class TestKeyValue {
  Object? _value;

  TestKeyValue._(Object? value) : _value = value;

  factory TestKeyValue.value(String? value) => TestKeyValue._(value);

  factory TestKeyValue.values(List<String?>? values) => TestKeyValue._(values);

  Object? get value => _value;

  List<String?>? asList() => _value != null ? _value as List<String?> : null;

  String? asString() => _value != null ? _value as String? : null;

  Iterable<(String, String?)> expand(String key) sync* {
    if (asList() == null) {
      yield (key, asString());
    } else {
      for (var i = 0; i < asList()!.length; i++) {
        yield ('$key:$i', asList()![i]);
      }
    }
  }
}

class AsOptions {
  AsOptions(this.key1, this.section1, this.section3);

  String key1;
  Section1AsOptions section1;
  Section3AsOptions section3;
}

class Section1AsOptions {
  Section1AsOptions(this.key2, this.section2);
  String key2;
  Section2AsOptions section2;
}

class Section2AsOptions {
  Section2AsOptions(this.key3, this.key3a);

  String key3;
  List<String> key3a;
}

class Section3AsOptions {
  Section3AsOptions(this.section4);

  Section4AsOptions section4;
}

class Section4AsOptions {
  Section4AsOptions(this.key4);

  String key4;
}
