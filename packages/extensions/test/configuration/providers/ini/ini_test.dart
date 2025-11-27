import 'package:extensions/configuration.dart';
import 'package:test/test.dart';

import '../../common/configuration_provider_extensions.dart';

void main() {
  group('IniConfigurationTest', () {
    test('LoadKeyValuePairsFromValidIni', () {
      const ini = '''
[DefaultConnection]
ConnectionString=TestConnectionString
Provider=SqlClient

[Data:Inventory]
ConnectionString=AnotherTestConnectionString
SubHeader:Provider=MySql
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('defaultconnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(iniConfig.get('DefaultConnection:Provider'), equals('SqlClient'));
      expect(iniConfig.get('Data:Inventory:CONNECTIONSTRING'),
          equals('AnotherTestConnectionString'));
      expect(
          iniConfig.get('Data:Inventory:SubHeader:Provider'), equals('MySql'));
    });

    test('LoadMethodCanHandleEmptyValue', () {
      const ini = '''
[DefaultConnection]
DefaultKey=
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:DefaultKey'), equals(''));
    });

    test('LoadKeyValuePairsFromValidIniWithQuotedValues', () {
      const ini = '''
[DefaultConnection]
ConnectionString="TestConnectionString"
Provider='SqlClient'
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(iniConfig.get('DefaultConnection:Provider'), equals('SqlClient'));
    });

    test('DoubleQuoteIsPartOfValueIfNotPaired', () {
      const ini = '''
[DefaultConnection]
ConnectionString="TestConnectionString
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('"TestConnectionString'));
    });

    test('SingleQuoteIsPartOfValueIfNotPaired', () {
      const ini = '''
[DefaultConnection]
ConnectionString='TestConnectionString
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals("'TestConnectionString"));
    });

    test('DoubleQuoteIsPartOfValueIfAppearInTheMiddleOfValue', () {
      const ini = '''
[DefaultConnection]
ConnectionString=Test"Connection"String
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('Test"Connection"String'));
    });

    test('LoadKeyValuePairsFromValidIniWithoutSectionHeader', () {
      const ini = '''
DefaultConnection:ConnectionString=TestConnectionString
DefaultConnection:Provider=SqlClient
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(iniConfig.get('DefaultConnection:Provider'), equals('SqlClient'));
    });

    test('SupportAndIgnoreSemicolonComments', () {
      const ini = '''
; This is a comment
[DefaultConnection]
; Another comment
ConnectionString=TestConnectionString
Provider=SqlClient
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(iniConfig.get('DefaultConnection:Provider'), equals('SqlClient'));
    });

    test('SupportAndIgnoreHashComments', () {
      const ini = '''
# This is a comment
[DefaultConnection]
# Another comment
ConnectionString=TestConnectionString
Provider=SqlClient
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(iniConfig.get('DefaultConnection:Provider'), equals('SqlClient'));
    });

    test('SupportAndIgnoreSlashComments', () {
      const ini = '''
/ This is a comment
[DefaultConnection]
/ Another comment
ConnectionString=TestConnectionString
Provider=SqlClient
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(iniConfig.get('DefaultConnection:Provider'), equals('SqlClient'));
    });

    test('ShouldRemoveLeadingAndTrailingWhiteSpacesFromKeyAndValue', () {
      const ini = '''
[DefaultConnection]
 \t key \t = \t value\t
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('DefaultConnection:key'), equals('value'));
    });

    test('ShouldRemoveLeadingAndTrailingWhiteSpacesFromSectionName', () {
      const ini = '''
[ \t section \t ]
key=value
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('section:key'), equals('value'));
    });

    test('ThrowExceptionWhenFoundInvalidLine', () {
      const ini = '''
[DefaultConnection]
ConnectionString
''';

      expect(() {
        IniConfigurationProvider(ini).load();
      }, throwsFormatException);
    });

    test('ThrowExceptionWhenFoundBrokenSectionHeader', () {
      const ini = '''
[ConnectionString
key=value
''';

      expect(() {
        IniConfigurationProvider(ini).load();
      }, throwsFormatException);
    });

    test('ThrowExceptionWhenKeyIsDuplicated', () {
      const ini = '''
[Data:DefaultConnection]
ConnectionString=TestConnectionString

[Data]
DefaultConnection:ConnectionString=AnotherTestConnectionString
''';

      expect(() {
        IniConfigurationProvider(ini).load();
      }, throwsFormatException);
    });

    test('ThrowExceptionWhenEmptySectionName', () {
      const ini = '''
[]
key=value
''';

      expect(() {
        IniConfigurationProvider(ini).load();
      }, throwsFormatException);
    });

    test('ThrowExceptionWhenEmptyKey', () {
      const ini = '''
[section]
=value
''';

      expect(() {
        IniConfigurationProvider(ini).load();
      }, throwsFormatException);
    });

    test('LoadKeyValuePairsWithMultipleSections', () {
      const ini = '''
[Section1]
Key1=Value1
Key2=Value2

[Section2]
Key1=Value3
Key2=Value4

[Section3]
Key1=Value5
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('Section1:Key1'), equals('Value1'));
      expect(iniConfig.get('Section1:Key2'), equals('Value2'));
      expect(iniConfig.get('Section2:Key1'), equals('Value3'));
      expect(iniConfig.get('Section2:Key2'), equals('Value4'));
      expect(iniConfig.get('Section3:Key1'), equals('Value5'));
    });

    test('LoadKeyValuePairsWithNestedSections', () {
      const ini = '''
[Parent:Child]
Key1=Value1

[Parent:Child:GrandChild]
Key2=Value2
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('Parent:Child:Key1'), equals('Value1'));
      expect(iniConfig.get('Parent:Child:GrandChild:Key2'), equals('Value2'));
    });

    test('LoadWithBlankLines', () {
      const ini = '''

[Section1]

Key1=Value1


Key2=Value2

''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('Section1:Key1'), equals('Value1'));
      expect(iniConfig.get('Section1:Key2'), equals('Value2'));
    });

    test('LoadWithMixedQuoteStyles', () {
      const ini = '''
[Section]
DoubleQuoted="value1"
SingleQuoted='value2'
Unquoted=value3
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('Section:DoubleQuoted'), equals('value1'));
      expect(iniConfig.get('Section:SingleQuoted'), equals('value2'));
      expect(iniConfig.get('Section:Unquoted'), equals('value3'));
    });

    test('CaseInsensitiveKeyAccess', () {
      const ini = '''
[MySection]
MyKey=MyValue
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('mysection:mykey'), equals('MyValue'));
      expect(iniConfig.get('MYSECTION:MYKEY'), equals('MyValue'));
      expect(iniConfig.get('MySection:MyKey'), equals('MyValue'));
      expect(iniConfig.get('mysection:MyKey'), equals('MyValue'));
    });

    test('ValuesWithEqualsSign', () {
      const ini = '''
[Section]
Key=Value=With=Equals
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('Section:Key'), equals('Value=With=Equals'));
    });

    test('ValuesWithSpecialCharacters', () {
      const ini = '''
[Section]
Key1=Value!@#\$%^&*()
Key2=Value with spaces
Key3=Value:with:colons
''';

      final iniConfig = IniConfigurationProvider(ini)..load();

      expect(iniConfig.get('Section:Key1'), equals('Value!@#\$%^&*()'));
      expect(iniConfig.get('Section:Key2'), equals('Value with spaces'));
      expect(iniConfig.get('Section:Key3'), equals('Value:with:colons'));
    });
  });

  group('IniConfigurationExtensionsTest', () {
    test('AddIni_LoadsConfiguration', () {
      const ini = '''
[Section]
Key=Value
''';

      final config = ConfigurationBuilder().addIni(ini).build();

      expect(config['Section:Key'], equals('Value'));
    });

    test('AddIni_LoadsMultipleSources', () {
      const ini1 = '''
[Section1]
Key1=Value1
''';

      const ini2 = '''
[Section2]
Key2=Value2
''';

      final config = ConfigurationBuilder().addIni(ini1).addIni(ini2).build();

      expect(config['Section1:Key1'], equals('Value1'));
      expect(config['Section2:Key2'], equals('Value2'));
    });

    test('AddIni_LastSourceWins', () {
      const ini1 = '''
[Section]
Key=Value1
''';

      const ini2 = '''
[Section]
Key=Value2
''';

      final config = ConfigurationBuilder().addIni(ini1).addIni(ini2).build();

      expect(config['Section:Key'], equals('Value2'));
    });
  });
}
