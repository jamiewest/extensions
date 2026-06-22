import 'package:extensions/src/primitives/cancellation_change_token.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('CancellationChangeToken', () {
    test('registration keeps activeChangeCallbacks true', () {
      final cts = CancellationTokenSource();
      final changeToken = CancellationChangeToken(cts.token);

      changeToken.registerChangeCallback((_) {}, null);

      expect(changeToken.activeChangeCallbacks, isTrue);
    });

    test('a throwing user callback does not disable proactive callbacks', () {
      final cts = CancellationTokenSource();
      final changeToken = CancellationChangeToken(cts.token);

      changeToken.registerChangeCallback((_) => throw Exception('boom'), null);

      // The exception surfaces through cancel(); it must not be swallowed and
      // must not flip the token out of active-callback mode.
      expect(() => cts.cancel(), throwsA(isA<Exception>()));
      expect(changeToken.activeChangeCallbacks, isTrue);
    });

    test('hasChanged reflects the underlying token', () {
      final cts = CancellationTokenSource();
      final changeToken = CancellationChangeToken(cts.token);

      expect(changeToken.hasChanged, isFalse);
      cts.cancel();
      expect(changeToken.hasChanged, isTrue);
    });
  });
}
