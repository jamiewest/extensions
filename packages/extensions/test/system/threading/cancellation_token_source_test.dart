import 'package:extensions/src/system/exceptions/aggregate_exception.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('CancellationTokenSource', () {
    test('cancel runs registered callbacks and sets requested state', () {
      final cts = CancellationTokenSource();
      var fired = 0;
      cts.token.register((_) => fired++);

      cts.cancel();

      expect(fired, equals(1));
      expect(cts.isCancellationRequested, isTrue);
    });

    test('registering on an already-canceled source runs the callback now', () {
      final cts = CancellationTokenSource()..cancel();
      var fired = 0;

      cts.token.register((_) => fired++);

      expect(fired, equals(1));
    });

    test('cancelAfter(zero) still notifies callbacks', () async {
      final cts = CancellationTokenSource();
      var fired = 0;
      cts.token.register((_) => fired++);

      cts.cancelAfter(Duration.zero);
      // The timer fires on a later event-loop tick.
      await Future<void>.delayed(Duration.zero);

      expect(fired, equals(1));
      expect(cts.isCancellationRequested, isTrue);
    });

    test('cancelAfter(delay) notifies callbacks after the delay', () async {
      final cts = CancellationTokenSource();
      var fired = 0;
      cts.token.register((_) => fired++);

      cts.cancelAfter(const Duration(milliseconds: 10));
      expect(fired, equals(0));

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(fired, equals(1));
      expect(cts.isCancellationRequested, isTrue);
    });

    test('callback exceptions are aggregated, not discarded', () {
      final cts = CancellationTokenSource();
      cts.token.register((_) => throw Exception('first'));
      cts.token.register((_) => throw Exception('second'));

      try {
        cts.cancel();
        fail('Expected an AggregateException to be thrown.');
      } on AggregateException catch (ex) {
        expect(ex.innerExceptions, hasLength(2));
      }
    });

    test('throwOnFirstException rethrows the first error directly', () {
      final cts = CancellationTokenSource();
      cts.token.register((_) => throw Exception('boom'));

      expect(
        () => cts.cancel(true),
        throwsA(
          allOf(
            isA<Exception>(),
            isNot(isA<AggregateException>()),
            predicate<Object>((e) => e.toString().contains('boom')),
          ),
        ),
      );
    });

    test('using a disposed source throws ObjectDisposedException', () {
      final cts = CancellationTokenSource()..dispose();

      expect(() => cts.cancel(), throwsA(isA<ObjectDisposedException>()));
      expect(() => cts.token, throwsA(isA<ObjectDisposedException>()));
    });

    test('registering through a disposed source is a safe no-op', () {
      final cts = CancellationTokenSource();
      final token = cts.token;
      cts.dispose();

      final registration = token.register((_) {});

      // Disposing the empty registration must not throw.
      expect(registration.dispose, returnsNormally);
    });
  });
}
