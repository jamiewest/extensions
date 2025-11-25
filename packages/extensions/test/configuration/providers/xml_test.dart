import 'package:extensions/configuration.dart';
import 'package:test/test.dart';

import '../common/configuration_provider_extensions.dart';

void main() {
  group('XmlConfigurationTest', () {
    test('LoadKeyValuePairsFromValidXml', () {
      const xml = '''
<settings>
  <Data>
    <DefaultConnection>
      <ConnectionString>TestConnectionString</ConnectionString>
      <Provider>SqlClient</Provider>
    </DefaultConnection>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:data:DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(xmlConfig.get('settings:Data:DEFAULTCONNECTION:PROVIDER'),
          equals('SqlClient'));
    });

    test('LoadXmlWithAttributes', () {
      const xml = '''
<settings Port="8008">
  <Data Server="localhost" />
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Port'), equals('8008'));
      expect(xmlConfig.get('settings:Data:Server'), equals('localhost'));
    });

    test('LoadXmlWithNameAttribute', () {
      const xml = '''
<settings>
  <Data Name="DefaultConnection">
    <ConnectionString>TestConnectionString</ConnectionString>
    <Provider>SqlClient</Provider>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:DefaultConnection:ConnectionString'),
          equals('TestConnectionString'));
      expect(xmlConfig.get('settings:Data:DefaultConnection:Provider'),
          equals('SqlClient'));
    });

    test('LoadXmlWithLowercaseNameAttribute', () {
      const xml = '''
<settings>
  <data name="defaultconnection">
    <connectionstring>TestConnectionString</connectionstring>
  </data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:data:defaultconnection:connectionstring'),
          equals('TestConnectionString'));
    });

    test('LoadXmlWithRepeatedElements', () {
      const xml = '''
<settings>
  <Data>
    <DefaultConnection />
    <DefaultConnection />
    <DefaultConnection />
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:DefaultConnection:0'), equals(''));
      expect(xmlConfig.get('settings:Data:DefaultConnection:1'), equals(''));
      expect(xmlConfig.get('settings:Data:DefaultConnection:2'), equals(''));
    });

    test('LoadXmlWithRepeatedElementsHavingContent', () {
      const xml = '''
<settings>
  <Servers>
    <Server>Server1</Server>
    <Server>Server2</Server>
    <Server>Server3</Server>
  </Servers>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Servers:Server:0'), equals('Server1'));
      expect(xmlConfig.get('settings:Servers:Server:1'), equals('Server2'));
      expect(xmlConfig.get('settings:Servers:Server:2'), equals('Server3'));
    });

    test('LoadXmlWithEmptyValue', () {
      const xml = '''
<settings>
  <Data>
    <DefaultKey></DefaultKey>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:DefaultKey'), equals(''));
    });

    test('LoadXmlWithSelfClosingElement', () {
      const xml = '''
<settings>
  <Data>
    <DefaultKey />
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:DefaultKey'), equals(''));
    });

    test('LoadXmlWithCDATA', () {
      const xml = '''
<settings>
  <Data>
    <Content><![CDATA[Text with <special> characters & symbols]]></Content>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:Content'),
          equals('Text with <special> characters & symbols'));
    });

    test('LoadXmlWithComments', () {
      const xml = '''
<!-- This is a comment -->
<settings>
  <!-- Another comment -->
  <Data>
    <Key>Value</Key>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:Key'), equals('Value'));
    });

    test('LoadXmlWithMixedContent', () {
      const xml = '''
<settings>
  <Data>
    <Key>Value1 Value2</Key>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:Key'), equals('Value1 Value2'));
    });

    test('LoadXmlWithAttributeAndContent', () {
      const xml = '''
<settings>
  <Data attr="attrValue">Content</Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data'), equals('Content'));
      expect(xmlConfig.get('settings:Data:attr'), equals('attrValue'));
    });

    test('ThrowExceptionWhenNamespaceIsUsed', () {
      const xml = '''
<settings xmlns="http://example.com">
  <Data>Value</Data>
</settings>
''';

      expect(() {
        XmlConfigurationProvider(xml).load();
      }, throwsFormatException);
    });

    test('LoadXmlWithRepeatedParentElements', () {
      // In XML, repeated elements at the same level get indexed
      const xml = '''
<settings>
  <Data>
    <Key>Value1</Key>
  </Data>
  <Data>
    <Key>Value2</Key>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      // Repeated Data elements are indexed
      expect(xmlConfig.get('settings:Data:0:Key'), equals('Value1'));
      expect(xmlConfig.get('settings:Data:1:Key'), equals('Value2'));
    });

    test('LoadXmlWithNestedRepeatedElements', () {
      const xml = '''
<settings>
  <Connections>
    <Connection>
      <Server>Server1</Server>
      <Server>Server2</Server>
    </Connection>
    <Connection>
      <Server>Server3</Server>
    </Connection>
  </Connections>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Connections:Connection:0:Server:0'),
          equals('Server1'));
      expect(xmlConfig.get('settings:Connections:Connection:0:Server:1'),
          equals('Server2'));
      expect(xmlConfig.get('settings:Connections:Connection:1:Server'),
          equals('Server3'));
    });

    test('LoadXmlWithComplexHierarchy', () {
      const xml = '''
<settings Environment="Production">
  <Database Name="Primary">
    <Connection>
      <Server>localhost</Server>
      <Port>5432</Port>
    </Connection>
    <Credentials Username="admin">
      <Password>secret</Password>
    </Credentials>
  </Database>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Environment'), equals('Production'));
      expect(xmlConfig.get('settings:Database:Primary:Connection:Server'),
          equals('localhost'));
      expect(xmlConfig.get('settings:Database:Primary:Connection:Port'),
          equals('5432'));
      expect(xmlConfig.get('settings:Database:Primary:Credentials:Username'),
          equals('admin'));
      expect(xmlConfig.get('settings:Database:Primary:Credentials:Password'),
          equals('secret'));
    });

    test('LoadXmlWithEmptyAttributes', () {
      const xml = '''
<settings>
  <Data attr="" />
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:attr'), equals(''));
    });

    test('CaseInsensitiveKeyAccess', () {
      const xml = '''
<settings>
  <MySection>
    <MyKey>MyValue</MyKey>
  </MySection>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:mysection:mykey'), equals('MyValue'));
      expect(xmlConfig.get('SETTINGS:MYSECTION:MYKEY'), equals('MyValue'));
      expect(xmlConfig.get('settings:MySection:MyKey'), equals('MyValue'));
    });

    test('LoadXmlWithWhitespaceInContent', () {
      const xml = '''
<settings>
  <Data>
    <Key>
      Value with whitespace
    </Key>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(
          xmlConfig.get('settings:Data:Key'), equals('Value with whitespace'));
    });

    test('LoadXmlWithMultipleTextNodes', () {
      const xml = '''
<settings>
  <Data>
    <Key>Part1 Part2 Part3</Key>
  </Data>
</settings>
''';

      final xmlConfig = XmlConfigurationProvider(xml)..load();

      expect(xmlConfig.get('settings:Data:Key'), equals('Part1 Part2 Part3'));
    });
  });

  group('XmlConfigurationExtensionsTest', () {
    test('AddXml_LoadsConfiguration', () {
      const xml = '''
<settings>
  <Section>
    <Key>Value</Key>
  </Section>
</settings>
''';

      final config = ConfigurationBuilder().addXml(xml).build();

      expect(config['settings:Section:Key'], equals('Value'));
    });

    test('AddXml_LoadsMultipleSources', () {
      const xml1 = '''
<settings>
  <Section1>
    <Key1>Value1</Key1>
  </Section1>
</settings>
''';

      const xml2 = '''
<settings>
  <Section2>
    <Key2>Value2</Key2>
  </Section2>
</settings>
''';

      final config = ConfigurationBuilder().addXml(xml1).addXml(xml2).build();

      expect(config['settings:Section1:Key1'], equals('Value1'));
      expect(config['settings:Section2:Key2'], equals('Value2'));
    });

    test('AddXml_LastSourceWins', () {
      const xml1 = '''
<settings>
  <Section>
    <Key>Value1</Key>
  </Section>
</settings>
''';

      const xml2 = '''
<settings>
  <Section>
    <Key>Value2</Key>
  </Section>
</settings>
''';

      final config = ConfigurationBuilder().addXml(xml1).addXml(xml2).build();

      expect(config['settings:Section:Key'], equals('Value2'));
    });
  });
}
