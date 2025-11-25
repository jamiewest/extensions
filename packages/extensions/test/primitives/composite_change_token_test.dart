import 'package:extensions/primitives.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('CompositeChangeToken', () {
    group('Constructor', () {
      test('Constructor_ThrowsForNullTokens', () {
        expect(
          // ignore: unnecessary_cast
          () => CompositeChangeToken(null as List<IChangeToken>),
          throwsA(isA<ArgumentNullException>()),
        );
      });

      test('Constructor_AcceptsEmptyList', () {
        final token = CompositeChangeToken([]);
        expect(token.changeTokens, isEmpty);
      });

      test('Constructor_StoresTokens', () {
        final token1 = TestChangeToken();
        final token2 = TestChangeToken();
        final composite = CompositeChangeToken([token1, token2]);

        expect(composite.changeTokens, hasLength(2));
        expect(composite.changeTokens, contains(token1));
        expect(composite.changeTokens, contains(token2));
      });
    });

    group('HasChanged', () {
      test('HasChanged_IsFalse_WhenNoTokensHaveChanged', () {
        final token1 = TestChangeToken();
        final token2 = TestChangeToken();
        final composite = CompositeChangeToken([token1, token2]);

        expect(composite.hasChanged, isFalse);
      });

      test('HasChanged_IsTrue_WhenAnyTokenHasChanged', () {
        final token1 = TestChangeToken();
        final token2 = TestChangeToken();
        final composite = CompositeChangeToken([token1, token2]);

        token1.changed = true;

        expect(composite.hasChanged, isTrue);
      });

      test('HasChanged_IsTrue_WhenAllTokensHaveChanged', () {
        final token1 = TestChangeToken();
        final token2 = TestChangeToken();
        final composite = CompositeChangeToken([token1, token2]);

        token1.changed = true;
        token2.changed = true;

        expect(composite.hasChanged, isTrue);
      });

      test('HasChanged_IsFalse_WhenTokenListIsEmpty', () {
        final composite = CompositeChangeToken([]);
        expect(composite.hasChanged, isFalse);
      });
    });

    group('ActiveChangeCallbacks', () {
      test('ActiveChangeCallbacks_IsFalse_WhenNoTokensHaveActiveCallbacks', () {
        final token1 = TestChangeToken(activeCallbacks: false);
        final token2 = TestChangeToken(activeCallbacks: false);
        final composite = CompositeChangeToken([token1, token2]);

        expect(composite.activeChangeCallbacks, isFalse);
      });

      test('ActiveChangeCallbacks_IsTrue_WhenAnyTokenHasActiveCallbacks', () {
        final token1 = TestChangeToken(activeCallbacks: false);
        final token2 = TestChangeToken(activeCallbacks: true);
        final composite = CompositeChangeToken([token1, token2]);

        expect(composite.activeChangeCallbacks, isTrue);
      });

      test('ActiveChangeCallbacks_IsTrue_WhenAllTokensHaveActiveCallbacks', () {
        final token1 = TestChangeToken(activeCallbacks: true);
        final token2 = TestChangeToken(activeCallbacks: true);
        final composite = CompositeChangeToken([token1, token2]);

        expect(composite.activeChangeCallbacks, isTrue);
      });

      test('ActiveChangeCallbacks_IsFalse_WhenTokenListIsEmpty', () {
        final composite = CompositeChangeToken([]);
        expect(composite.activeChangeCallbacks, isFalse);
      });
    });

    group('RegisterChangeCallback', () {
      test('RegisterChangeCallback_InvokesCallback_WhenAnyTokenChanges', () {
        final cts1 = CancellationTokenSource();
        final cts2 = CancellationTokenSource();

        final token1 = CancellationChangeToken(cts1.token);
        final token2 = CancellationChangeToken(cts2.token);
        final composite = CompositeChangeToken([token1, token2]);

        var callbackInvoked = false;
        composite.registerChangeCallback((_) {
          callbackInvoked = true;
        }, null);

        cts1.cancel();

        expect(callbackInvoked, isTrue);
      });

      test('RegisterChangeCallback_InvokesOnlyOnce_WhenMultipleTokensChange',
          () {
        final cts1 = CancellationTokenSource();
        final cts2 = CancellationTokenSource();

        final token1 = CancellationChangeToken(cts1.token);
        final token2 = CancellationChangeToken(cts2.token);
        final composite = CompositeChangeToken([token1, token2]);

        var callbackCount = 0;
        composite.registerChangeCallback((_) {
          callbackCount++;
        }, null);

        cts1.cancel();
        cts2.cancel();

        expect(callbackCount, equals(1));
      });

      test('RegisterChangeCallback_PassesState', () {
        final cts = CancellationTokenSource();
        final token = CancellationChangeToken(cts.token);
        final composite = CompositeChangeToken([token]);

        const testState = 'test state';
        Object? receivedState;

        composite.registerChangeCallback((state) {
          receivedState = state;
        }, testState);

        cts.cancel();

        expect(receivedState, equals(testState));
      });

      test('RegisterChangeCallback_ReturnsDisposable', () {
        final token1 = TestChangeToken();
        final token2 = TestChangeToken();
        final composite = CompositeChangeToken([token1, token2]);

        final disposable = composite.registerChangeCallback((_) {}, null);

        expect(disposable, isNotNull);
        expect(disposable, isA<Disposable>());
      });

      test('RegisterChangeCallback_DisposePreventsCallback', () {
        final cts = CancellationTokenSource();
        final token = CancellationChangeToken(cts.token);
        final composite = CompositeChangeToken([token]);

        var callbackInvoked = false;
        final disposable = composite.registerChangeCallback((_) {
          callbackInvoked = true;
        }, null);

        disposable.dispose();
        cts.cancel();

        expect(callbackInvoked, isFalse);
      });

      test(
          'RegisterChangeCallback_DoesNotInvokeCallback_'
          'WhenTokenDoesNotChange', () {
        final token1 = TestChangeToken();
        final token2 = TestChangeToken();
        final composite = CompositeChangeToken([token1, token2]);

        var callbackInvoked = false;
        composite.registerChangeCallback((_) {
          callbackInvoked = true;
        }, null);

        // Don't change any tokens
        expect(callbackInvoked, isFalse);
      });
    });

    group('Multiple Tokens', () {
      test('CompositeToken_WithManyTokens_InvokesCallbackOnce', () {
        final tokenSources = List.generate(10, (_) => CancellationTokenSource());
        final tokens =
            tokenSources.map((cts) => CancellationChangeToken(cts.token)).toList();
        final composite = CompositeChangeToken(tokens);

        var callbackCount = 0;
        composite.registerChangeCallback((_) {
          callbackCount++;
        }, null);

        // Cancel all tokens
        for (final cts in tokenSources) {
          cts.cancel();
        }

        expect(callbackCount, equals(1));
      });

      test('CompositeToken_WithMixedTokens_DetectsChange', () {
        final unchangedToken = TestChangeToken();
        final cts = CancellationTokenSource();
        final changingToken = CancellationChangeToken(cts.token);

        final composite =
            CompositeChangeToken([unchangedToken, changingToken]);

        expect(composite.hasChanged, isFalse);

        cts.cancel();

        expect(composite.hasChanged, isTrue);
      });
    });

    group('Lazy Initialization', () {
      test('CompositeToken_DoesNotRegisterCallbacks_UntilNeeded', () {
        final trackingToken = TrackingChangeToken();
        final composite = CompositeChangeToken([trackingToken]);

        // Just creating the composite shouldn't register callbacks
        expect(trackingToken.registrationCount, equals(0));

        // Accessing hasChanged shouldn't register callbacks
        // ignore: unnecessary_statements
        composite.hasChanged;
        expect(trackingToken.registrationCount, equals(0));

        // Only registering a callback should trigger registration
        composite.registerChangeCallback((_) {}, null);
        expect(trackingToken.registrationCount, equals(1));
      });
    });

    group('Resource Management', () {
      test('CompositeToken_DisposesUnchangedTokenRegistrations', () {
        final cts1 = CancellationTokenSource();
        final cts2 = CancellationTokenSource();

        final token1 = CancellationChangeToken(cts1.token);
        final token2 = CancellationChangeToken(cts2.token);
        final composite = CompositeChangeToken([token1, token2]);

        final disposable = composite.registerChangeCallback((_) {}, null);

        // Cancel first token
        cts1.cancel();

        // Dispose the registration
        disposable.dispose();

        // Should work without errors (resources cleaned up properly)
        expect(() => disposable.dispose(), returnsNormally);
      });
    });

    group('Edge Cases', () {
      test('CompositeToken_WithSingleToken_Behaves correctly', () {
        final cts = CancellationTokenSource();
        final token = CancellationChangeToken(cts.token);
        final composite = CompositeChangeToken([token]);

        var callbackInvoked = false;
        composite.registerChangeCallback((_) {
          callbackInvoked = true;
        }, null);

        cts.cancel();

        expect(callbackInvoked, isTrue);
        expect(composite.hasChanged, isTrue);
      });

      test('CompositeToken_AlreadyChangedToken_InvokesImmediately', () {
        final token = TestChangeToken(changed: true);
        final composite = CompositeChangeToken([token]);

        expect(composite.hasChanged, isTrue);

        var callbackInvoked = false;
        composite.registerChangeCallback((_) {
          callbackInvoked = true;
        }, null);

        // Callback should be invoked immediately since token already changed
        expect(callbackInvoked, isTrue);
      });
    });
  });
}

/// No-op disposable for testing.
class _NoOpDisposable implements Disposable {
  const _NoOpDisposable._();

  static const instance = _NoOpDisposable._();

  @override
  void dispose() {}
}

class _ChangeTokenDisposable implements Disposable {
  _ChangeTokenDisposable(this._disposeAction);

  final void Function() _disposeAction;
  bool _disposed = false;

  @override
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _disposeAction();
    }
  }
}

/// Test implementation of IChangeToken for testing.
class TestChangeToken implements IChangeToken {
  TestChangeToken({this.changed = false, this.activeCallbacks = true});

  bool changed;
  final bool activeCallbacks;
  final List<ChangeCallback> _callbacks = [];

  @override
  bool get hasChanged => changed;

  @override
  bool get activeChangeCallbacks => activeCallbacks;

  @override
  Disposable registerChangeCallback(ChangeCallback callback, Object? state) {
    if (hasChanged) {
      callback(state);
      return _NoOpDisposable.instance;
    }

    _callbacks.add(callback);
    return _ChangeTokenDisposable(() {
      _callbacks.remove(callback);
    });
  }

  void triggerChange() {
    changed = true;
    for (final callback in List.of(_callbacks)) {
      callback(null);
    }
    _callbacks.clear();
  }
}

/// Tracks callback registrations for testing lazy initialization.
class TrackingChangeToken implements IChangeToken {
  int registrationCount = 0;

  @override
  bool get hasChanged => false;

  @override
  bool get activeChangeCallbacks => true;

  @override
  Disposable registerChangeCallback(ChangeCallback callback, Object? state) {
    registrationCount++;
    return _NoOpDisposable.instance;
  }
}
