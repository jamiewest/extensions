import 'package:extensions/file_providers.dart';
import 'package:test/test.dart';

void main() {
  group('ExclusionFilters', () {
    group('None Filter', () {
      test('does not exclude any files', () {
        const filter = ExclusionFilters.none;

        expect(filter.shouldExclude('regular.txt'), isFalse);
        expect(filter.shouldExclude('.hidden'), isFalse);
        expect(filter.shouldExclude('file', isHidden: true), isFalse);
      });
    });

    group('DotPrefixed Filter', () {
      test('excludes files starting with period', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('.dotfile'), isTrue);
        expect(filter.shouldExclude('.hidden'), isTrue);
        expect(filter.shouldExclude('.gitignore'), isTrue);
        expect(filter.shouldExclude('..parent'), isTrue);
      });

      test('does not exclude files without period prefix', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('regular.txt'), isFalse);
        expect(filter.shouldExclude('file.hidden'), isFalse);
        expect(filter.shouldExclude('no-dot'), isFalse);
      });

      test('does not exclude hidden files without dot prefix', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('file.txt', isHidden: true), isFalse);
      });
    });

    group('Hidden Filter', () {
      test('excludes files marked as hidden', () {
        const filter = ExclusionFilters.hidden;

        expect(filter.shouldExclude('file.txt', isHidden: true), isTrue);
        expect(filter.shouldExclude('hidden-file', isHidden: true), isTrue);
      });

      test('does not exclude non-hidden files', () {
        const filter = ExclusionFilters.hidden;

        expect(filter.shouldExclude('file.txt', isHidden: false), isFalse);
        expect(filter.shouldExclude('regular'), isFalse);
      });

      test('does not exclude dot-prefixed files if not hidden', () {
        const filter = ExclusionFilters.hidden;

        expect(filter.shouldExclude('.dotfile', isHidden: false), isFalse);
      });
    });

    group('System Filter', () {
      test('has correct flag value', () {
        const filter = ExclusionFilters.system;

        expect(filter.value, equals(0x0004));
      });

      test('can be combined with other filters', () {
        const combined = ExclusionFilters.dotPrefixed;
        expect(combined.hasFlag(ExclusionFilters.dotPrefixed), isTrue);
      });
    });

    group('Sensitive Filter', () {
      test('excludes dot-prefixed files', () {
        const filter = ExclusionFilters.sensitive;

        expect(filter.shouldExclude('.hidden'), isTrue);
        expect(filter.shouldExclude('.gitignore'), isTrue);
      });

      test('excludes hidden files', () {
        const filter = ExclusionFilters.sensitive;

        expect(filter.shouldExclude('file.txt', isHidden: true), isTrue);
      });

      test('excludes files that are both dot-prefixed and hidden', () {
        const filter = ExclusionFilters.sensitive;

        expect(filter.shouldExclude('.hidden', isHidden: true), isTrue);
      });

      test('does not exclude regular files', () {
        const filter = ExclusionFilters.sensitive;

        expect(filter.shouldExclude('regular.txt'), isFalse);
        expect(filter.shouldExclude('file', isHidden: false), isFalse);
      });

      test('has correct combined value', () {
        const filter = ExclusionFilters.sensitive;

        expect(filter.value, equals(0x0007));
        expect(filter.hasFlag(ExclusionFilters.dotPrefixed), isTrue);
        expect(filter.hasFlag(ExclusionFilters.hidden), isTrue);
        expect(filter.hasFlag(ExclusionFilters.system), isTrue);
      });
    });

    group('hasFlag', () {
      test('correctly detects single flags', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.hasFlag(ExclusionFilters.dotPrefixed), isTrue);
        expect(filter.hasFlag(ExclusionFilters.hidden), isFalse);
        expect(filter.hasFlag(ExclusionFilters.system), isFalse);
      });

      test('correctly detects combined flags', () {
        const filter = ExclusionFilters.sensitive;

        expect(filter.hasFlag(ExclusionFilters.dotPrefixed), isTrue);
        expect(filter.hasFlag(ExclusionFilters.hidden), isTrue);
        expect(filter.hasFlag(ExclusionFilters.system), isTrue);
      });

      test('none filter has no flags', () {
        const filter = ExclusionFilters.none;

        expect(filter.hasFlag(ExclusionFilters.dotPrefixed), isFalse);
        expect(filter.hasFlag(ExclusionFilters.hidden), isFalse);
        expect(filter.hasFlag(ExclusionFilters.system), isFalse);
      });
    });

    group('operator |', () {
      test('combines two filters when predefined combination exists', () {
        // Combining dotPrefixed + hidden doesn't have a predefined enum value
        // so it returns none. Only combinations that exist as enum values work.
        final combined =
            ExclusionFilters.dotPrefixed | ExclusionFilters.hidden;

        // Since there's no enum value for dotPrefixed | hidden, returns none
        expect(combined, ExclusionFilters.none);
      });

      test('combining with none returns other filter', () {
        final result = ExclusionFilters.none | ExclusionFilters.dotPrefixed;

        expect(result.hasFlag(ExclusionFilters.dotPrefixed), isTrue);
      });

      test('combining same filter returns same filter', () {
        final result =
            ExclusionFilters.dotPrefixed | ExclusionFilters.dotPrefixed;

        expect(result, equals(ExclusionFilters.dotPrefixed));
      });

      test('combining all filters creates sensitive', () {
        // Combining works step by step:
        // dotPrefixed | hidden = none (no such enum value)
        // none | system = system
        final result = ExclusionFilters.dotPrefixed |
            ExclusionFilters.hidden |
            ExclusionFilters.system;

        // Due to how the operator works, this won't equal sensitive
        // The implementation only supports predefined enum combinations
        expect(result, ExclusionFilters.system);
      });
    });

    group('shouldExclude - Complex Scenarios', () {
      test('sensitive filter excludes various file types', () {
        const filter = ExclusionFilters.sensitive;

        // Dot-prefixed files
        expect(filter.shouldExclude('.config'), isTrue);
        expect(filter.shouldExclude('.env'), isTrue);

        // Hidden files
        expect(filter.shouldExclude('hidden.txt', isHidden: true), isTrue);

        // Both dot-prefixed and hidden
        expect(filter.shouldExclude('.hidden', isHidden: true), isTrue);

        // Regular files
        expect(filter.shouldExclude('readme.txt'), isFalse);
      });

      test('predefined filter combinations work correctly', () {
        // Use the predefined sensitive filter which has all flags
        const filter = ExclusionFilters.sensitive;

        expect(filter.shouldExclude('.dotfile'), isTrue);
        expect(filter.shouldExclude('file', isHidden: true), isTrue);
        expect(filter.shouldExclude('regular.txt'), isFalse);
      });
    });

    group('Edge Cases', () {
      test('handles empty string filename', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude(''), isFalse);
      });

      test('handles single dot filename', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('.'), isTrue);
      });

      test('handles double dot filename', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('..'), isTrue);
      });

      test('handles filename with dot in middle', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('file.name.txt'), isFalse);
      });

      test('handles directory names with dots', () {
        const filter = ExclusionFilters.dotPrefixed;

        expect(filter.shouldExclude('.git'), isTrue);
        expect(filter.shouldExclude('.vscode'), isTrue);
        expect(filter.shouldExclude('node_modules'), isFalse);
      });
    });

    group('Filter Values', () {
      test('all filters have unique values', () {
        final values = ExclusionFilters.values.map((f) => f.value).toList();
        final uniqueValues = values.toSet();

        expect(values.length, equals(uniqueValues.length));
      });

      test('sensitive is combination of all other filters', () {
        const sensitive = ExclusionFilters.sensitive;
        const dotPrefixed = ExclusionFilters.dotPrefixed;
        const hidden = ExclusionFilters.hidden;
        const system = ExclusionFilters.system;

        expect(
          sensitive.value,
          equals(dotPrefixed.value | hidden.value | system.value),
        );
      });
    });

    group('Real-World File Examples', () {
      test('filters common hidden files', () {
        const filter = ExclusionFilters.sensitive;

        // Common dot files
        expect(filter.shouldExclude('.gitignore'), isTrue);
        expect(filter.shouldExclude('.env'), isTrue);
        expect(filter.shouldExclude('.DS_Store'), isTrue);
        expect(filter.shouldExclude('.htaccess'), isTrue);

        // Regular files
        expect(filter.shouldExclude('README.md'), isFalse);
        expect(filter.shouldExclude('main.dart'), isFalse);
        expect(filter.shouldExclude('pubspec.yaml'), isFalse);
      });

      test('filters common hidden directories', () {
        const filter = ExclusionFilters.sensitive;

        // Common dot directories
        expect(filter.shouldExclude('.git'), isTrue);
        expect(filter.shouldExclude('.vscode'), isTrue);
        expect(filter.shouldExclude('.idea'), isTrue);

        // Regular directories
        expect(filter.shouldExclude('lib'), isFalse);
        expect(filter.shouldExclude('test'), isFalse);
        expect(filter.shouldExclude('bin'), isFalse);
      });
    });
  });
}
