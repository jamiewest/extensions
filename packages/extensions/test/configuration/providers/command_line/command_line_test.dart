import 'dart:collection';

import 'package:extensions/src/configuration/providers/command_line/command_line_configuration_provider.dart';
import 'package:test/test.dart';
import '../../common/configuration_provider_extensions.dart';

void main() {
  group('CommandLineTest', () {
    test('IgnoresOnlyUnknownArgs', () {
      var args = <String>[
        'foo',
        '/bar=baz',
      ];

      var cmdLineConfig =
          CommandLineConfigurationProvider(args, null) // Fix this null
            ..load();

      expect(cmdLineConfig.getChildKeys(<String>[], null).length, equals(1));
      expect(cmdLineConfig.get('bar'), equals('baz'));
    });

    test('CanIgnoreValuesInMiddle', () {
      var args = <String>[
        'Key1=Value1',
        '--Key2=Value2',
        '/Key3=Value3',
        'Bogus1',
        '--Key4',
        'Value4',
        'Bogus2',
        '/Key5',
        'Value5',
        'Bogus3'
      ];

      var cmdLineConfig =
          CommandLineConfigurationProvider(args, null) // Fix this null
            ..load();

      expect(cmdLineConfig.get('Key1'), equals('Value1'));
      expect(cmdLineConfig.get('Key2'), equals('Value2'));
      expect(cmdLineConfig.get('Key3'), equals('Value3'));
      expect(cmdLineConfig.get('Key4'), equals('Value4'));
      expect(cmdLineConfig.get('Key5'), equals('Value5'));
      expect(cmdLineConfig.getChildKeys(<String>[], null).length, equals(5));
    });

    test('LoadKeyValuePairsFromCommandLineArgumentsWithoutSwitchMappings', () {
      var args = <String>[
        'Key1=Value1',
        '--Key2=Value2',
        '/Key3=Value3',
        '--Key4',
        'Value4',
        '/Key5',
        'Value5'
      ];

      var cmdLineConfig =
          CommandLineConfigurationProvider(args, null) // Fix this null
            ..load();

      expect(cmdLineConfig.get('Key1'), equals('Value1'));
      expect(cmdLineConfig.get('Key2'), equals('Value2'));
      expect(cmdLineConfig.get('Key3'), equals('Value3'));
      expect(cmdLineConfig.get('Key4'), equals('Value4'));
      expect(cmdLineConfig.get('Key5'), equals('Value5'));
    });

    test('LoadKeyValuePairsFromCommandLineArgumentsWithSwitchMappings', () {
      var args = <String>[
        '-K1=Value1',
        '--Key2=Value2',
        '/Key3=Value3',
        '--Key4',
        'Value4',
        '/Key5',
        'Value5',
        '/Key6=Value6'
      ];

      var switchMappings = LinkedHashMap<String, String>(
        equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
        hashCode: (k) => k.toLowerCase().hashCode,
      );

      switchMappings['-K1'] = 'LongKey1';
      switchMappings['--Key2'] = 'SuperLongKey2';
      switchMappings['--Key6'] = 'SuchALongKey6';

      var cmdLineConfig = CommandLineConfigurationProvider(args, switchMappings)
        ..load();

      expect(cmdLineConfig.get('LongKey1'), equals('Value1'));
      expect(cmdLineConfig.get('SuperLongKey2'), equals('Value2'));
      expect(cmdLineConfig.get('Key3'), equals('Value3'));
      expect(cmdLineConfig.get('Key4'), equals('Value4'));
      expect(cmdLineConfig.get('Key5'), equals('Value5'));
      expect(cmdLineConfig.get('SuchALongKey6'), equals('Value6'));
    });

    test('ThrowExceptionWhenPassingSwitchMappingsWithDuplicatedKeys', () {
      // // Arrange
      // var args = new string[]
      //     {
      //         "-K1=Value1",
      //         "--Key2=Value2",
      //         "/Key3=Value3",
      //         "--Key4", "Value4",
      //         "/Key5", "Value5"
      //     };
      // var switchMappings = new Dictionary<string, string>
      // (StringComparer.Ordinal)
      //     {
      //         { "--KEY1", "LongKey1" },
      //         { "--key1", "SuperLongKey1" },
      //         { "-Key2", "LongKey2" },
      //         { "-KEY2", "LongKey2"}
      //     };

      // // Find out the duplicate expected be be reported
      // var expectedDup = string.Empty;
      // var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
      // foreach (var mapping in switchMappings)
      // {
      //     if (set.Contains(mapping.Key))
      //     {
      //         expectedDup = mapping.Key;
      //         break;
      //     }

      //     set.Add(mapping.Key);
      // }

      // var expectedMsg = new ArgumentException(SR.
      //     Format(SR.Error_DuplicatedKeyInSwitchMappings, expectedDup),
      // "switchMappings").Message;

      // // Act
      // var exception = Assert.Throws<ArgumentException>(
      //     () => new CommandLineConfigurationProvider(args, switchMappings));

      // // Assert
      // Assert.Equal(expectedMsg, exception.Message);
    });

    test('ThrowExceptionWhenSwitchMappingsContainInvalidKey', () {
      // var args = new string[]
      //     {
      //         "-K1=Value1",
      //         "--Key2=Value2",
      //         "/Key3=Value3",
      //         "--Key4", "Value4",
      //         "/Key5", "Value5"
      //     };
      // var switchMappings = new Dictionary<string,
      // string>(StringComparer.OrdinalIgnoreCase)
      //     {
      //         { "-K1", "LongKey1" },
      //         { "--Key2", "SuperLongKey2" },
      //         { "/Key3", "AnotherSuperLongKey3" }
      //     };
      // var expectedMsg = new ArgumentException(SR.Format
      // (SR.Error_InvalidSwitchMapping,"/Key3"),
      //     "switchMappings").Message;

      // var exception = Assert.Throws<ArgumentException>(
      //     () => new CommandLineConfigurationProvider(args, switchMappings));

      // Assert.Equal(expectedMsg, exception.Message);
    });

    test('ThrowExceptionWhenNullIsPassedToConstructorAsArgs', () {
      // string[] args = null;
      // var expectedMsg = new ArgumentNullException("args").Message;

      // var exception = Assert.Throws<ArgumentNullException>(() =>
      //new CommandLineConfigurationProvider(args));

      // Assert.Equal(expectedMsg, exception.Message);
    });

    test('OverrideValueWhenKeyIsDuplicated', () {
      var args = <String>[
        '/Key1=Value1',
        '--Key1=Value2',
      ];

      var cmdLineConfig = CommandLineConfigurationProvider(args, null)..load();
      expect(cmdLineConfig.get('Key1'), equals('Value2'));
    });

    test('IgnoreWhenValueForAKeyIsMissing', () {
      var args = <String>[
        '--Key1',
        'Value1',
        '/Key2' /* The value for Key2 is missing here */
      ];

      var cmdLineConfig = CommandLineConfigurationProvider(args, null)..load();
      expect(cmdLineConfig.getChildKeys(<String>[], null).length, equals(1));
      expect(cmdLineConfig.get('Key1'), equals('Value1'));
    });

    test('IgnoreWhenAnArgumentCannotBeRecognized', () {
      var args = <String>['ArgWithoutPrefixAndEqualSign'];
      var cmdLineConfig = CommandLineConfigurationProvider(args, null)..load();
      expect(cmdLineConfig.getChildKeys(<String>[], null), isEmpty);
    });

    test('IgnoreWhenShortSwitchNotDefined', () {
      var args = <String>[
        '-Key1',
        'Value1',
      ];

      var switchMappings = LinkedHashMap<String, String>(
        equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
        hashCode: (k) => k.toLowerCase().hashCode,
      );

      switchMappings['-Key2'] = 'LongKey2';

      var cmdLineConfig = CommandLineConfigurationProvider(args, switchMappings)
        ..load();

      expect(cmdLineConfig.getChildKeys(<String>[], ''), isEmpty);
    });
  });
}
