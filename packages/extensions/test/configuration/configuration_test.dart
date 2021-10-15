import 'package:extensions/configuration.dart';
import 'package:test/test.dart';
import 'common/configuration_provider_extensions.dart';

void main() {
  group('Configuration', () {
    test('LoadAndCombineKeyValuePairsFromDifferentConfigurationProviders', () {
      // Arrange
      var dic1 = <String, String>{'Mem1:KeyInMem1': 'ValueInMem1'}.entries;
      var dic2 = <String, String>{'Mem2:KeyInMem2': 'ValueInMem2'}.entries;
      var dic3 = <String, String>{'Mem3:KeyInMem3': 'ValueInMem3'}.entries;

      var memConfigSrc1 = MemoryConfigurationSource()..initialData = dic1;
      var memConfigSrc2 = MemoryConfigurationSource()..initialData = dic2;
      var memConfigSrc3 = MemoryConfigurationSource()..initialData = dic3;

      var configurationBuilder = ConfigurationBuilder()
        // Act
        ..add(memConfigSrc1)
        ..add(memConfigSrc2)
        ..add(memConfigSrc3);

      var config = configurationBuilder.build();

      var memVal1 = config['mem1:keyinmem1'];
      var memVal2 = config['Mem2:KeyInMem2'];
      var memVal3 = config['MEM3:KEYINMEM3'];

      expect(memVal1, equals('ValueInMem1'));
      expect(memVal2, equals('ValueInMem2'));
      expect(memVal3, equals('ValueInMem3'));

      expect(config['mem1:keyinmem1'], equals('ValueInMem1'));
      expect(config['Mem2:KeyInMem2'], equals('ValueInMem2'));
      expect(config['MEM3:KEYINMEM3'], equals('ValueInMem3'));
    });

    test('CanChainConfiguration', () {
      // Arrange
      var dic1 = <String, String>{'Mem1:KeyInMem1': 'ValueInMem1'}.entries;
      var dic2 = <String, String>{'Mem2:KeyInMem2': 'ValueInMem2'}.entries;
      var dic3 = <String, String>{'Mem3:KeyInMem3': 'ValueInMem3'}.entries;

      var memConfigSrc1 = MemoryConfigurationSource()..initialData = dic1;
      var memConfigSrc2 = MemoryConfigurationSource()..initialData = dic2;
      var memConfigSrc3 = MemoryConfigurationSource()..initialData = dic3;

      var configurationBuilder = ConfigurationBuilder()
        // Act
        ..add(memConfigSrc1)
        ..add(memConfigSrc2)
        ..add(memConfigSrc3);

      var config = configurationBuilder.build();

      var chained = ConfigurationBuilder().addConfiguration(config).build();
      var memVal1 = chained['mem1:keyinmem1'];
      var memVal2 = chained['Mem2:KeyInMem2'];
      var memVal3 = chained['MEM3:KEYINMEM3'];

      expect(memVal1, equals('ValueInMem1'));
      expect(memVal2, equals('ValueInMem2'));
      expect(memVal3, equals('ValueInMem3'));

      expect(chained['NotExist'], equals(null));
    });

    test('ChainedAsEnumerateFlattensIntoDictionaryTest', () {
      var dic1 = <String, String>{
        'Mem1': 'Value1',
        'Mem1:': 'NoKeyValue1',
        'Mem1:KeyInMem1': 'ValueInMem1',
        'Mem1:KeyInMem1:Deep1': 'ValueDeep1',
      }.entries;

      var dic2 = <String, String>{
        'Mem2': 'Value2',
        'Mem2:': 'NoKeyValue2',
        'Mem2:KeyInMem2': 'ValueInMem2',
        'Mem2:KeyInMem2:Deep2': 'ValueDeep2',
      }.entries;

      var dic3 = <String, String>{
        'Mem3': 'Value3',
        'Mem3:': 'NoKeyValue3',
        'Mem3:KeyInMem3': 'ValueInMem3',
        'Mem3:KeyInMem3:Deep3': 'ValueDeep3',
      }.entries;

      var memConfigSrc1 = MemoryConfigurationSource()..initialData = dic1;
      var memConfigSrc2 = MemoryConfigurationSource()..initialData = dic2;
      var memConfigSrc3 = MemoryConfigurationSource()..initialData = dic3;

      var configurationBuilder = ConfigurationBuilder()
        // Act
        ..add(memConfigSrc1)
        ..add(memConfigSrc2);

      var config = ConfigurationBuilder()
          .addConfiguration(configurationBuilder.build())
          .add(memConfigSrc3)
          .build();

      var dict = {for (var item in config.asEnumerable()) item.key: item.value};

      expect(dict['Mem1'], equals('Value1'));
      expect(dict['Mem1:'], equals('NoKeyValue1'));
      expect(dict['Mem1:KeyInMem1:Deep1'], equals('ValueDeep1'));
      expect(dict['Mem2:KeyInMem2'], equals('ValueInMem2'));
      expect(dict['Mem2'], equals('Value2'));
      expect(dict['Mem2:'], equals('NoKeyValue2'));
      expect(dict['Mem2:KeyInMem2:Deep2'], equals('ValueDeep2'));
      expect(dict['Mem3'], equals('Value3'));
      expect(dict['Mem3:'], equals('NoKeyValue3'));
      expect(dict['Mem3:KeyInMem3'], equals('ValueInMem3'));
      expect(dict['Mem3:KeyInMem3:Deep3'], equals('ValueDeep3'));
    });

    test('AsEnumerateStripsKeyFromChildren', () {
      var dic1 = <String, String>{
        'Mem1': 'Value1',
        'Mem1:': 'NoKeyValue1',
        'Mem1:KeyInMem1': 'ValueInMem1',
        'Mem1:KeyInMem1:Deep1': 'ValueDeep1'
      }.entries;

      var dic2 = <String, String>{
        'Mem2': 'Value2',
        'Mem2:': 'NoKeyValue2',
        'Mem2:KeyInMem2': 'ValueInMem2',
        'Mem2:KeyInMem2:Deep2': 'ValueDeep2'
      }.entries;

      var dic3 = <String, String>{
        'Mem3': 'Value3',
        'Mem3:': 'NoKeyValue3',
        'Mem3:KeyInMem3': 'ValueInMem3',
        'Mem3:KeyInMem4': 'ValueInMem4',
        'Mem3:KeyInMem3:Deep3': 'ValueDeep3',
        'Mem3:KeyInMem3:Deep4': 'ValueDeep4'
      }.entries;

      var memConfigSrc1 = MemoryConfigurationSource()..initialData = dic1;
      var memConfigSrc2 = MemoryConfigurationSource()..initialData = dic2;
      var memConfigSrc3 = MemoryConfigurationSource()..initialData = dic3;

      var configurationBuilder = ConfigurationBuilder()
        // Act
        ..add(memConfigSrc1)
        ..add(memConfigSrc2)
        ..add(memConfigSrc3);

      var config = configurationBuilder.build();

      var dict = {
        for (var item
            in config.getSection('Mem1').asEnumerable(makePathsRelative: true))
          item.key: item.value
      };
      expect(dict.length, equals(3));
      expect(dict[''], equals('NoKeyValue1'));
      expect(dict['KeyInMem1'], equals('ValueInMem1'));
      expect(dict['KeyInMem1:Deep1'], equals('ValueDeep1'));

      var dict2 = {
        for (var item
            in config.getSection('Mem2').asEnumerable(makePathsRelative: true))
          item.key: item.value
      };
      expect(dict2.length, equals(3));
      expect(dict2[''], equals('NoKeyValue2'));
      expect(dict2['KeyInMem2'], equals('ValueInMem2'));
      expect(dict2['KeyInMem2:Deep2'], equals('ValueDeep2'));

      var dict3 = {
        for (var item
            in config.getSection('Mem3').asEnumerable(makePathsRelative: true))
          item.key: item.value
      };
      expect(dict2.length, equals(3));
      expect(dict3[''], equals('NoKeyValue3'));
      expect(dict3['KeyInMem3'], equals('ValueInMem3'));
      expect(dict3['KeyInMem4'], equals('ValueInMem4'));
      expect(dict3['KeyInMem3:Deep3'], equals('ValueDeep3'));
      expect(dict3['KeyInMem3:Deep4'], equals('ValueDeep4'));
    });

    test('NewConfigurationProviderOverridesOldOneWhenKeyIsDuplicated', () {
      // Arrange
      var dic1 = <String, String>{
        'Key1:Key2': 'ValueInMem1',
      };

      var dic2 = <String, String>{
        'Key1:Key2': 'ValueInMem2',
      };

      var memConfigSrc1 = MemoryConfigurationSource()
        ..initialData = dic1.entries;
      var memConfigSrc2 = MemoryConfigurationSource()
        ..initialData = dic2.entries;

      // Act
      var configurationBuilder = ConfigurationBuilder()
        ..add(memConfigSrc1)
        ..add(memConfigSrc2);

      var config = configurationBuilder.build();

      // Assert
      expect(config['Key1:Key2'], equals('ValueInMem2'));
    });

    test('NewConfigurationRootMayBeBuiltFromExistingWithDuplicateKeys', () {
      var configurationRoot = ConfigurationBuilder()
          .addInMemoryCollection({'keya:keyb': 'valueA'}.entries)
          .addInMemoryCollection({'KEYA:KEYB': 'valueB'}.entries)
          .build();

      var newConfigurationRoot = ConfigurationBuilder()
          .addInMemoryCollection(configurationRoot.asEnumerable())
          .build();

      expect(newConfigurationRoot['keya:keyb'], equals('valueB'));
    });

    test('SettingValueUpdatesAllConfigurationProviders', () {
      // Arrange
      var dict = {
        'Key1': 'Value1',
        'Key2': 'Value2',
      }.entries;

      var memConfigSrc1 = TestMemorySourceProvider(dict);
      var memConfigSrc2 = TestMemorySourceProvider(dict);
      var memConfigSrc3 = TestMemorySourceProvider(dict);

      var configurationBuilder = ConfigurationBuilder()
        ..add(memConfigSrc1)
        ..add(memConfigSrc2)
        ..add(memConfigSrc3);

      var config = configurationBuilder.build();

      // Act
      config['Key1'] = 'NewValue1';
      config['Key2'] = 'NewValue2';

      var memConfigProvider1 = memConfigSrc1.build(configurationBuilder);
      var memConfigProvider2 = memConfigSrc2.build(configurationBuilder);
      var memConfigProvider3 = memConfigSrc3.build(configurationBuilder);

      expect(config['Key1'], equals('NewValue1'));
      expect(memConfigProvider1.get('Key1'), equals('NewValue1'));
      expect(memConfigProvider2.get('Key1'), equals('NewValue1'));
      expect(memConfigProvider3.get('Key1'), equals('NewValue1'));
      expect(config['Key2'], equals('NewValue2'));
      expect(memConfigProvider1.get('Key2'), equals('NewValue2'));
      expect(memConfigProvider2.get('Key2'), equals('NewValue2'));
      expect(memConfigProvider3.get('Key2'), equals('NewValue2'));
    });
  });
}

class TestMemorySourceProvider extends MemoryConfigurationProvider
    implements ConfigurationSource {
  TestMemorySourceProvider(Iterable<MapEntry<String, String>> initialData)
      : super(MemoryConfigurationSource()..initialData = initialData);

  @override
  ConfigurationProvider build(ConfigurationBuilder builder) => this;
}
