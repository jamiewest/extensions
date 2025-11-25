import 'package:extensions/system.dart' hide equals;
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
      // var temp1 = inflatedEmptyCT1.canBeCanceled;
      var inflatedEmptyCT2 = CancellationToken();
      // var temp2 = inflatedEmptyCT2.canBeCanceled;

      expect(inflatedEmptyCT1, equals(CancellationToken()));
      expect(CancellationToken(), equals(inflatedEmptyCT1));

      expect(inflatedEmptyCT1, equals(inflatedEmptyCT2));

      // Inflated pre-set token comparisons
      var inflatedDefaultSetCT1 = CancellationToken(true);
      // var temp3 = inflatedDefaultSetCT1.canBeCanceled;
      var inflatedDefaultSetCT2 = CancellationToken(true);
      // var temp4 = inflatedDefaultSetCT2.canBeCanceled;

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

      var defaultUnsetToken1 = CancellationToken();
      var defaultUnsetToken2 = CancellationToken();
      var hashDefaultUnset1 = defaultUnsetToken1.hashCode;
      var hashDefaultUnset2 = defaultUnsetToken2.hashCode;
      expect(hashDefaultUnset2, equals(hashDefaultUnset1));

      var defaultSetToken1 = CancellationToken(true);
      var defaultSetToken2 = CancellationToken(true);
      var hashDefaultSet1 = defaultSetToken1.hashCode;
      var hashDefaultSet2 = defaultSetToken2.hashCode;
      expect(hashDefaultSet2, equals(hashDefaultSet1));

      expect(hashDefaultUnset1, isNot(equals(hash1)));
      expect(hashDefaultSet1, isNot(equals(hash1)));
      expect(hashDefaultSet1, isNot(equals(hashDefaultUnset1)));
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

    test('CreateLinkedTokenSource_Simple_MultiToken', () {
      var signal1 = CancellationTokenSource();
      var signal2 = CancellationTokenSource();
      var signal3 = CancellationTokenSource();

      var combined = CancellationTokenSource.createLinkedTokenSource([
        signal1.token,
        signal2.token,
        signal3.token,
      ]);
      expect(
        combined.isCancellationRequested,
        equals(false),
        reason: 'CreateLinkedToken_Simple_MultiToken:'
            ' The combined token should start unsignalled',
      );

      signal1.cancel();
      expect(
        combined.isCancellationRequested,
        equals(true),
        reason: 'CreateLinkedToken_Simple_MultiToken:'
            ' The combined token should now be signalled',
      );
    });

    test('CreateLinkedToken_SourceTokenAlreadySignalled_OneToken', () {
      // Creating a combined token, when a source token is already signaled.
      var signal = CancellationTokenSource()..cancel(); // Early signal.

      var combined =
          CancellationTokenSource.createLinkedTokenSource([signal.token]);

      expect(
        combined.isCancellationRequested,
        equals(true),
        reason: 'CreateLinkedToken_SourceTokenAlreadySignalled:'
            ' The combined token should immediately be in the signalled state.',
      );
    });

    test('CreateLinkedToken_SourceTokenAlreadySignalled_TwoTokens', () {
      // Creating a combined token, when a source token is already signaled.
      var signal1 = CancellationTokenSource();
      var signal2 = CancellationTokenSource();

      signal1.cancel();

      var combined = CancellationTokenSource.createLinkedTokenSource([
        signal1.token,
        signal2.token,
      ]);

      expect(
        combined.isCancellationRequested,
        equals(true),
        reason: 'CreateLinkedToken_SourceTokenAlreadySignalled:'
            ' The combined token should immediately be in the signalled state.',
      );
    });

    test('CreateLinkedToken_MultistepComposition_SourceTokenAlreadySignalled',
        () {
      // Two-step composition
      var signal1 = CancellationTokenSource()..cancel();

      var signal2 = CancellationTokenSource();
      var combined1 = CancellationTokenSource.createLinkedTokenSource([
        signal1.token,
        signal2.token,
      ]);

      var signal3 = CancellationTokenSource();
      var combined2 = CancellationTokenSource.createLinkedTokenSource([
        signal3.token,
        combined1.token,
      ]);

      expect(
        combined2.isCancellationRequested,
        equals(true),
        reason: 'CreateLinkedToken_MultistepComposition_SourceTokenAlready'
            'Signalled:  The 2-step combined token should immediately be in the'
            ' signalled state.',
      );
    });

    test('CallbacksOrderIsLifo', () {
      var tokenSource = CancellationTokenSource();
      var token = tokenSource.token;

      var callbackOutput = <String>[];
      token
        ..register((s) => callbackOutput.add('Callback1'))
        ..register((s) => callbackOutput.add('Callback2'));

      tokenSource.cancel();
      expect(callbackOutput[0], equals('Callback2'));
      expect(callbackOutput[1], equals('Callback1'));
    });

    test('Enlist_EarlyAndLate', () {
      var tokenSource = CancellationTokenSource();
      var token = tokenSource.token;

      var earlyenlistedTokenSource = CancellationTokenSource();

      token.register((state) => earlyenlistedTokenSource.cancel());
      tokenSource.cancel();

      expect(earlyenlistedTokenSource.isCancellationRequested, equals(true));

      var lateEnlistedTokenSource = CancellationTokenSource();
      token.register((state) => lateEnlistedTokenSource.cancel());
      expect(lateEnlistedTokenSource.isCancellationRequested, equals(true));
    });

    test('BehaviourAfterCancelSignalled', () {
      CancellationTokenSource()
        ..token
        ..register((state) {})
        ..cancel();
    });

    test('CancellationRegistration_RepeatDispose', () {
      Exception? caughtException;

      var cts = CancellationTokenSource();
      var ct = cts.token;

      var registration = ct.register((state) {});

      try {
        registration
          ..dispose()
          ..dispose();
      } on Exception catch (ex) {
        caughtException = ex;
      }

      expect(caughtException, isNull);
    });

    test('CancellationTokenRegistration_Token_AccessibleAfterCtsDispose', () {
      var cts = CancellationTokenSource();
      var ct = cts.token;
      var ctr = ct.register((state) {});

      cts.dispose();
      expect(() => cts.token, throwsException);

      expect(ctr.token, equals(ct));
      ctr.dispose();
      expect(ctr.token, ct);
    });

    test('CancellationTokenRegistration_UnregisterRemovesDelegate', () {
      var cts = CancellationTokenSource();
      var invoked = false;
      var ctr = cts.token.register((state) => invoked = true);
      expect(ctr.unregister(), equals(true));
      expect(ctr.unregister(), equals(false));
      cts.cancel();
      expect(invoked, equals(false));
    });
  });
}
