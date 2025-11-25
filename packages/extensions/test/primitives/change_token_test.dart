import 'package:extensions/primitives.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('ChangeTokenTests', () {
    test('HasChangeFiresChange', () {
      var token = TestChangeToken();
      var fired = false;
      ChangeToken.onChange(() => token, () => fired = true);
      expect(fired, isFalse);
      token.changed();
      expect(fired, isTrue);
    });

    test('ChangesFireAfterExceptions', () {
      TestChangeToken? token;
      var count = 0;
      ChangeToken.onChange(() => token = TestChangeToken(), () {
        count++;
        throw Exception();
      });
      expect(() => token!.changed(), throwsException);
      expect(count, equals(1));
      expect(() => token!.changed(), throwsException);
      expect(count, equals(2));
    });

    test('HasChangeFiresChangeWithState', () {
      var token = TestChangeToken();
      var state = Object();
      Object? callbackState;
      ChangeToken.onChangeWithState(
        () => token,
        (s) => callbackState = s,
        state,
      );
      expect(callbackState, isNull);
      token.changed();
      expect(callbackState, equals(state));
    });

    test('ChangesFireAfterExceptionsWithState', () {
      TestChangeToken? token;
      var count = 0;
      var state = Object();
      Object? callbackState;
      ChangeToken.onChangeWithState<Object>(
        () => token = TestChangeToken(),
        (s) {
          callbackState = s;
          count++;
          throw Exception();
        },
        state,
      );
      expect(() => token!.changed(), throwsException);
      expect(count, equals(1));
      expect(callbackState, isNotNull);
      expect(() => token!.changed(), throwsException);
      expect(count, equals(2));
      expect(callbackState, isNotNull);
    });

    test('DisposingChangeTokenRegistrationDuringCallbackWorks', () {
      var provider = _ResettableChangeTokenProvider();
      var count = 0;

      Disposable? reg;

      reg = ChangeToken.onChangeWithState<Object>(
        () => provider.getChangeToken(),
        (state) {
          count++;
          reg?.dispose();
        },
        null,
      );

      provider.changed();

      expect(count, equals(1));

      provider.changed();

      expect(count, equals(1));
    });

    test('DoubleDisposeDisposesOnce', () {
      var provider = TrackableChangeTokenProvider();
      var count = 0;

      Disposable? reg;

      reg = ChangeToken.onChangeWithState<Object>(
        () => provider.getChangeToken(),
        (state) {
          count++;
          reg?.dispose();
        },
        null,
      );

      provider.changed();

      expect(count, equals(1));
      expect(provider.registrationCalls, equals(1));
      expect(provider.disposeCalls, equals(1));

      reg.dispose();

      provider.changed();

      expect(count, equals(1));
      expect(provider.registrationCalls, equals(2));
      expect(provider.disposeCalls, equals(2));
    });
  });
}

class TestChangeToken implements IChangeToken {
  _VoidCallback? _callback;

  @override
  bool activeChangeCallbacks = false;

  @override
  bool hasChanged = false;

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    _callback = () => callback(state);
    return _NoopDisposable();
  }

  void changed() {
    hasChanged = true;
    _callback!();
  }
}

class _NoopDisposable implements IDisposable {
  @override
  void dispose() {}
}

class TrackableChangeTokenProvider {
  TrackableChangeToken _cts = TrackableChangeToken();

  int registrationCalls = 0;

  int disposeCalls = 0;

  IChangeToken getChangeToken() => _cts;

  void changed() {
    var previous = _cts;
    _cts = TrackableChangeToken();
    previous.execute();

    registrationCalls += previous.registrationCalls;
    disposeCalls += previous.disposeCalls;
  }
}

class TrackableChangeToken implements IChangeToken {
  final CancellationTokenSource _cts = CancellationTokenSource();

  int registrationCalls = 0;

  int disposeCalls = 0;

  @override
  bool get activeChangeCallbacks => true;

  @override
  bool get hasChanged => _cts.isCancellationRequested;

  void execute() {
    _cts.cancel();
  }

  @override
  IDisposable registerChangeCallback(
    void Function(Object? state) callback,
    Object? state,
  ) {
    var registration = _cts.token.register((s) => callback(s), state);
    registrationCalls++;

    return _DisposableAction(() {
      disposeCalls++;
      registration.dispose();
    });
  }
}

typedef _VoidCallback = void Function();

class _DisposableAction implements IDisposable {
  final _VoidCallback? _action;

  _DisposableAction(_VoidCallback action) : _action = action;

  @override
  void dispose() => _action?.call();
}

class _ResettableChangeTokenProvider {
  CancellationTokenSource _cts = CancellationTokenSource();

  IChangeToken getChangeToken() => CancellationChangeToken(_cts.token);

  void changed() {
    var previous = _cts;
    _cts = CancellationTokenSource();
    previous.cancel();
  }
}
