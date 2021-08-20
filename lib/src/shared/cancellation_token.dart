import 'dart:async';
import 'dart:collection';

import 'disposable.dart';
import 'operation_cancelled_exception.dart';

/// Propagates notification that operations should be canceled.
///
/// A [CancellationToken] may be created directly in an unchangeable
/// canceled or non-canceled state using the CancellationToken's constructors.
/// However, to have a CancellationToken that can change from a non-canceled
/// to a canceled state, [CancellationTokenSource] must be used.
/// CancellationTokenSource exposes the associated CancellationToken that may
/// be canceled by the source through its `token` property.
///
/// Once canceled, a token may not transition to a non-canceled state, and a
/// token whose `CanBeCanceled` is false will never change to one that can be
/// canceled.
class CancellationToken {
  // The backing TokenSource.
  // if null, it implicitly represents the same thing as
  // CancellationToken(false). When required, it will be
  // instantiated to reflect this.
  final CancellationTokenSource? _source;

  /// Internal constructor only a [CancellationTokenSource] should create a
  /// [CancellationToken].
  const CancellationToken._([CancellationTokenSource? source])
      : _source = source;

  /// Creates a [CancellationToken] that can be canceled.
  ///
  /// Tokens created with this constructor will remain in the canceled state
  /// specified by the [canceled] parameter. If [canceled] is `false`, both
  /// [canBeCanceled] and [isCancellationRequested] will be `false`.
  factory CancellationToken([bool canceled = false]) => CancellationToken._(
        canceled ? CancellationTokenSource._canceledSource : null,
      );

  /// Returns an empty CancellationToken value.
  ///
  /// This property indicates whether cancellation has been requested for this
  /// token, either through the token initially being constructed in a canceled
  /// state, or through calling `cancel` on the token's associated
  /// [CancellationTokenSource].
  static CancellationToken get none => const CancellationToken._();

  /// Gets whether this token is capable of being in the canceled state.
  ///
  /// If CanBeCanceled returns false, it is guaranteed that the token will
  /// never transition into a canceled state, meaning that
  /// `isCancellationRequested` will never return true.
  bool get canBeCanceled => _source != null;

  /// Gets whether cancellation has been requested for this token.
  bool get isCancellationRequested =>
      _source != null && _source!.isCancellationRequested;

  /// Registers a callback that will be called when the [CancellationToken] is
  /// canceled.
  CancellationTokenRegistration register(CallbackRegistration? callback,
      [Object? state]) {
    var source = _source;

    if (callback == null) {
      throw ArgumentError.notNull('callback');
    }

    if (source != null) {
      return source.register(callback, state);
    }

    return CancellationTokenRegistration(0, null);
  }

  /// Throws a [OperationCanceledException] if this token has had cancellation
  /// requested.
  void throwIfCancellationRequested() {
    if (isCancellationRequested) {
      _throwOperationCanceledException();
    }
  }

  void _throwOperationCanceledException() {
    throw OperationCanceledException('', this);
  }

  @override
  bool operator ==(Object other) {
    if (other is CancellationToken) {
      return _source == other._source;
    }
    return false;
  }

  @override
  int get hashCode =>
      (_source ?? CancellationTokenSource._canceledSource).hashCode;
}

typedef CallbackRegistration = void Function(Object? state);

class CancellationTokenRegistration extends Disposable {
  final int _id;
  final _CancellationCallbackInfo? _node;

  CancellationTokenRegistration(int id, _CancellationCallbackInfo? node)
      : _id = id,
        _node = node;

  bool unregister() {
    if (_node != null) {
      return _node!.registrations.unregister(_id, _node!);
    }
    return false;
  }

  @override
  void dispose() {}
}

typedef TimerCallback = void Function(CancellationTokenSource source);

/// Signals to a [CancellationToken] that it should be canceled.
///
/// [CancellationTokenSource] is used to instantiate a [CancellationToken] (via
/// the source's `token` that can be handed to operations that wish to be
/// notified of cancellation or that can be used to register asynchronous
/// operations for cancellation. That token may have cancellation requested
/// by calling to the source's `cancel()` method.
class CancellationTokenSource extends Disposable {
  // A [CancellationTokenSource] that's already canceled.
  static final CancellationTokenSource _canceledSource =
      CancellationTokenSource().._state = 2;

  // A [CancellationTokenSource] that's never canceled. This isn't enforced
  // programatically, only by usage. Do not cancel!
  // static final CancellationTokenSource _s_neverCanceledSource =
  //     CancellationTokenSource();

  // Used by [cancelAfter] and Timer-related ctors.
  Timer? _timer;

  // static final Function _s_timerCallback =
  //     (o) => (o as CancellationTokenSource)._notifyCancellation(false);

  //static const TimerCallback _s_timerCallback = _timerCallback;

  static void _timerCallback(Object? state) =>
      (state! as CancellationTokenSource)._notifyCancellation(false);

  // The current state of the CancellationTokenSource.
  int _state;

  // Wether this [CancellationTokenSource] has been disposed.
  bool _disposed;
  final List<_CancellationCallbackInfo> _registeredCallbacks;

  Registrations? _registrations;

  final int _notCanceledState = 0; // default value of _state
  final int _notifyingState = 1;
  final int _notifyingCompleteState = 2;

  CancellationTokenSource([Duration? delay])
      : _registeredCallbacks = <_CancellationCallbackInfo>[],
        _state = 0,
        _disposed = false {
    if (delay != null) {
      _timer = Timer(delay, () => _timerCallback.call(this));
    }

    _registrations = Registrations(this);
  }

  /// Gets whether cancellation has been requested for this
  /// [CancellationTokenSource].
  bool get isCancellationRequested => _state != _notCanceledState;

  /// A simple helper to determine whether cancellation has finished.
  bool get _isCancellationCompleted => _state == _notifyingCompleteState;

  /// Gets the CancellationToken associated with this
  /// [CancellationTokenSource].
  CancellationToken get token {
    _throwIfDisposed();
    return CancellationToken._(this);
  }

  /// Communicates a request for cancellation.
  ///
  /// The associated [CancellationToken] will be notified of the cancellation
  /// and will transition to state where [isCancellationRequested] returns
  /// true. Any callbacks of cancelable operations registered with the
  /// [CancellationToken] will be executed.
  void cancel([bool throwOnFirstException = false]) {
    _throwIfDisposed();
    _notifyCancellation(throwOnFirstException);
  }

  /// Schedules a Cancel operation on this [CancellationTokenSource].
  void cancelAfter(Duration delay) {
    _throwIfDisposed();

    if (isCancellationRequested) {
      return;
    }

    if (delay == Duration.zero) {
      _state = _notifyingCompleteState;
    }

    _timer ??= Timer(delay, () => _timerCallback(this));
  }

  void _notifyCancellation(bool throwOnFirstException) {
    if (!isCancellationRequested) {
      _state = _notifyingState;
      _executeCallbackHandlers(throwOnFirstException);
      assert(
        _isCancellationCompleted,
        'Expected cancellation to have finished',
      );
    }
  }

  /// Invoke all registered callbacks.
  ///
  /// The handlers are invoked synchronously in LIFO order.
  void _executeCallbackHandlers(bool throwOnFirstException) {
    assert(
      isCancellationRequested,
      '''ExecuteCallbackHandlers should only be called 
        after setting IsCancellationRequested->true''',
    );

    if (_registeredCallbacks.isEmpty) {
      _state = _notifyingCompleteState;
      return;
    }

    List<Exception>? exceptionsList;

    try {
      for (var callback in _registeredCallbacks) {
        callback.callback(callback.state);
      }
    } on Exception catch (e) {
      if (throwOnFirstException) {
        rethrow;
      }

      exceptionsList ??= <Exception>[];
      exceptionsList.add(e);
    } finally {
      _state = _notifyingCompleteState;
    }

    if (exceptionsList != null) {
      assert(
        exceptionsList.isNotEmpty,
        'Expected ${exceptionsList.length.toString} > 0',
      );
    }
  }

  CancellationTokenRegistration register(CancellationCallback callback,
      [Object? state]) {
    final callbackInfo = _CancellationCallbackInfo(
      id: _registrations!.nextAvailableId++,
      callback: callback,
      stateForCallback: state,
      registrations: _registrations!,
    );

    _registeredCallbacks.add(callbackInfo);

    return CancellationTokenRegistration(callbackInfo.id, callbackInfo);
  }

  /// Throws an exception if the source has been disposed;
  void _throwIfDisposed() {
    if (_disposed) {
      // ThrowHelper.ThrowObjectDisposedException
      // (ExceptionResource.CancellationTokenSource_Disposed);
    }
  }

  @override
  void dispose() {
    _disposed = true;
  }

  /// Creates a [CancellationTokenSource] that will be in the canceled state
  /// when any of the source tokens are in the canceled state.
  static CancellationTokenSource createLinkedTokenSource(
          List<CancellationToken> tokens) =>
      LinkedNCancellationTokenSource(tokens);
}

class LinkedNCancellationTokenSource extends CancellationTokenSource {
  final List<CancellationTokenRegistration> _linkingRegistrations =
      <CancellationTokenRegistration>[];
  final List<CancellationToken> _tokens;

  LinkedNCancellationTokenSource(List<CancellationToken> tokens)
      : _tokens = tokens {
    for (var i = 0; i < tokens.length; i++) {
      if (_tokens[i].canBeCanceled) {
        _linkingRegistrations.add(_tokens[i].register((a) {}, this));
      }
    }
  }

  @override
  void dispose() {
    for (var registration in _linkingRegistrations) {
      registration.dispose();
    }
    super.dispose();
  }
}

class Registrations with ListMixin<_CancellationCallbackInfo> {
  final List<_CancellationCallbackInfo> _nodes = <_CancellationCallbackInfo>[];

  int nextAvailableId = 1;

  /// Initializes the instance.
  Registrations(this.source);

  /// The associated source.
  final CancellationTokenSource source;

  bool unregister(int id, _CancellationCallbackInfo node) {
    if (id == 0) {
      return false;
    }

    _nodes.removeWhere((element) => element.id == id);
    return true;
  }

  @override
  int get length => _nodes.length;

  @override
  set length(int value) => _nodes.length = value;

  @override
  _CancellationCallbackInfo operator [](int index) => _nodes[index];

  @override
  void operator []=(int index, _CancellationCallbackInfo value) =>
      _nodes[index] = value;
}

typedef CancellationCallback = void Function(Object? state);

class _CancellationCallbackInfo {
  final Registrations registrations;
  final CancellationCallback _callback;
  final CancellationTokenSource? _cancellationTokenSource;
  final Object? _stateForCallback;
  final int id;

  _CancellationCallbackInfo({
    required this.id,
    required CancellationCallback callback,
    required this.registrations,
    Object? stateForCallback,
    CancellationTokenSource? cancellationTokenSource,
  })  : _callback = callback,
        _stateForCallback = stateForCallback,
        _cancellationTokenSource = cancellationTokenSource;

  CancellationCallback get callback => _callback;

  dynamic get state => _stateForCallback;

  CancellationTokenSource? get cancellationTokenSource =>
      _cancellationTokenSource;

  void executeCallback() {
    callback(state);
  }
}
