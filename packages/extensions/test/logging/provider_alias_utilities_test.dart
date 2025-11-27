import 'package:extensions/logging.dart';
import 'package:test/test.dart';

// Test provider types
class ConsoleLoggerProvider {}

class DebugLoggerProvider {}

class FileLoggerProvider {}

class CustomProvider {}

class LoggerProvider {}

void main() {
  group('ProviderAliasUtilities', () {
    group('getAlias', () {
      test('returns alias for standard logger provider', () {
        final alias = ProviderAliasUtilities.getAlias(ConsoleLoggerProvider);
        expect(alias, equals('Console'));
      });

      test('returns alias for debug logger provider', () {
        final alias = ProviderAliasUtilities.getAlias(DebugLoggerProvider);
        expect(alias, equals('Debug'));
      });

      test('returns alias for file logger provider', () {
        final alias = ProviderAliasUtilities.getAlias(FileLoggerProvider);
        expect(alias, equals('File'));
      });

      test('returns null for provider not following naming convention', () {
        final alias = ProviderAliasUtilities.getAlias(CustomProvider);
        expect(alias, isNull);
      });

      test('returns null for provider with only LoggerProvider suffix', () {
        final alias = ProviderAliasUtilities.getAlias(LoggerProvider);
        expect(alias, isNull);
      });
    });

    group('getFullName', () {
      test('returns full type name for console logger provider', () {
        final fullName =
            ProviderAliasUtilities.getFullName(ConsoleLoggerProvider);
        expect(fullName, equals('ConsoleLoggerProvider'));
      });

      test('returns full type name for debug logger provider', () {
        final fullName =
            ProviderAliasUtilities.getFullName(DebugLoggerProvider);
        expect(fullName, equals('DebugLoggerProvider'));
      });

      test('returns full type name for custom provider', () {
        final fullName = ProviderAliasUtilities.getFullName(CustomProvider);
        expect(fullName, equals('CustomProvider'));
      });
    });
  });
}
