import 'package:extensions/src/shared/cancellation_token.dart';
import 'package:test/test.dart';

void main() {
  group('CancellationTokenTests', () {
    test('CancellationTokenRegister_Exceptions', () {
      var token = CancellationToken();
      expect(() => token.register(null), throwsArgumentError);
    });

    test('CancellationTokenEquality', () {
      // Simple empty token comparisons
      expect(CancellationToken(), equals(CancellationToken()));

      // Inflated empty token comparisons
      var inflatedEmptyCT1 = CancellationToken();
      // ignore: unused_local_variable
      var temp1 = inflatedEmptyCT1.canBeCanceled;
      var inflatedEmptyCT2 = CancellationToken();
      // ignore: unused_local_variable
      var temp2 = inflatedEmptyCT2.canBeCanceled;

      expect(inflatedEmptyCT1, equals(CancellationToken()));
      expect(CancellationToken(), equals(inflatedEmptyCT1));

      expect(inflatedEmptyCT1, equals(inflatedEmptyCT2));

      // Inflated pre-set token comparisons
      var inflatedDefaultSetCT1 = CancellationToken(true);
      // ignore: unused_local_variable
      var temp3 = inflatedDefaultSetCT1.canBeCanceled;
      var inflatedDefaultSetCT2 = CancellationToken(true);
      // ignore: unused_local_variable
      var temp4 = inflatedDefaultSetCT2.canBeCanceled;

      expect(inflatedDefaultSetCT1, equals(CancellationToken(true)));
      expect(inflatedDefaultSetCT2, equals(inflatedDefaultSetCT2));

      // Things are not equal
      expect(inflatedEmptyCT1 == inflatedDefaultSetCT2, equals(false));
      expect(inflatedEmptyCT1 == CancellationToken(true), equals(false));
      expect(CancellationToken(true) == inflatedEmptyCT1, equals(false));
    });

    test('CancellationToken_GetHashCode', () {
      var cts = CancellationTokenSource();
      var ct = cts.token;
      var hash1 = cts.hashCode;
      var hash2 = cts.token.hashCode;
      var hash3 = ct.hashCode;

      expect(hash2, equals(hash1));
      expect(hash3, equals(hash2));
    });

    test('CreateLinkedTokenSource_OneToken', () {
      CancellationTokenSource original;
      original = CancellationTokenSource();
      var linked =
          CancellationTokenSource.createLinkedTokenSource([original.token]);
      expect(linked.token.isCancellationRequested, equals(false));
      linked.cancel();
      expect(linked.token.isCancellationRequested, equals(true));
      expect(original.isCancellationRequested, equals(false));
    });
  });
}
