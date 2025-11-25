import 'package:extensions/src/configuration/configuration_path.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigurationPathTest', () {
    test('CombineWithEmptySegmentLeavesDelimiter', () {
      expect(ConfigurationPath.combine(['parent', '']), 'parent:');
      expect(ConfigurationPath.combine(['parent', '', '']), 'parent::');
      expect(
          ConfigurationPath.combine(['parent', '', '', 'key']), 'parent:::key');
    });

    test('GetLastSegmenGetSectionKeyTests', () {
      expect(ConfigurationPath.getSectionKey(null), isNull);
      expect(ConfigurationPath.getSectionKey(''), '');
      expect(ConfigurationPath.getSectionKey(':::'), '');
      expect(ConfigurationPath.getSectionKey('a::b:::c'), 'c');
      expect(ConfigurationPath.getSectionKey('a:::b:'), '');
      expect(ConfigurationPath.getSectionKey('key'), 'key');
      expect(ConfigurationPath.getSectionKey(':key'), 'key');
      expect(ConfigurationPath.getSectionKey('::key'), 'key');
      expect(ConfigurationPath.getSectionKey('parent:key'), 'key');
    });

    test('GetParentPathTests', () {
      expect(ConfigurationPath.getParentPath(null), isNull);
      expect(ConfigurationPath.getParentPath(''), isNull);
      expect(ConfigurationPath.getParentPath(':::'), '::');
      expect(ConfigurationPath.getParentPath('a::b:::c'), 'a::b::');
      expect(ConfigurationPath.getParentPath('a:::b:'), 'a:::b');
      expect(ConfigurationPath.getParentPath('key'), isNull);
      expect(ConfigurationPath.getParentPath(':key'), '');
      expect(ConfigurationPath.getParentPath('::key'), ':');
      expect(ConfigurationPath.getParentPath('parent:key'), 'parent');
    });
  });
}
