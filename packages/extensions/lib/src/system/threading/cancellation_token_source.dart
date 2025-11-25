import 'dart:async';

import '../disposable.dart';
import 'cancellation_token.dart';
import 'cancellation_token_registration.dart';

/// Signals to a [CancellationToken] that it should be canceled.
///
/// [CancellationTokenSource] is used to instantiate a [CancellationToken] (via
/// the source's [token] that can be handed to operations that wish to be
/// notified of cancellation or that can be used to register asynchronous
/// operations for cancellation. That token may have cancellation requested
/// by calling to the source's [cancel] method.
class CancellationTokenSource implements IDisposable {
  // A [CancellationTokenSource] that's already canceled.
  static final CancellationTokenSource canceledSource =
      CancellationTokenSource().._state = 2;

  // A [CancellationTokenSource] that's never canceled. This isn't enforced
  // programatically, only by usage. Do not cancel!
  static final CancellationTokenSource neverCanceledSource =
      CancellationTokenSource();

  // Used by [cancelAfter] and Timer-related ctors.
  Timer? _timer;

  static void onTimer(Object? state) =>
      (state! as CancellationTokenSource)._notifyCancellation(false);

  /// The current state of the CancellationTokenSource.
  int _state = 0;

  /// Wether this [CancellationTokenSource] has been disposed.
  bool _disposed = false;
  //final List<CancellationCallbackInfo> _registeredCallbacks;

  /// Registration state for the source.
  Registrations? _registrations;

  // Legal values for _state;
  final int _notCanceledState = 0; // default value of _state
  final int _notifyingState = 1;
  final int _notifyingCompleteState = 2;

  /// Gets whether cancellation has been requested for this
  /// [CancellationTokenSource].
  ///
  /// This property indicates whether cancellation has been requested for
  /// this token source, such as due to a call to its [cancel] method.
  bool get isCancellationRequested => _state != _notCanceledState;

  /// A simple helper to determine whether cancellation has finished.
  bool get _isCancellationCompleted => _state == _notifyingCompleteState;

  /// Gets the CancellationToken associated with this
  /// [CancellationTokenSource].
  CancellationToken get token {
    _throwIfDisposed();
    return CancellationToken.fromSource(this);
  }

  CancellationTokenSource([Duration? delay]) {
    if (delay != null) {
      _timer = Timer(delay, () => onTimer(this));
    }

    _registrations = Registrations(this);
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

    _timer ??= Timer(delay, () => onTimer(this));
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

    if (_registrations == null) {
      _state = _notifyingCompleteState;
      return;
    }

    List<Exception>? exceptionsList;

    while (true) {
      CallbackNode? node;

      node = _registrations!.callbacks;
      if (node == null) {
        // No more registrations to process.
        break;
      }

      assert(node.registrations.source == this);
      assert(node.prev == null);

      if (node.next != null) {
        node.next?.prev = null;
      }
      _registrations!.callbacks = node.next;

      //_registrations!._executingCallbackId = node.id;

      node.id = 0;

      try {
        node.executeCallback();
      } on Exception catch (ex) {
        exceptionsList ??= <Exception>[ex];
      }
    }

    _state = _notifyingCompleteState;
    //_registrations!._executingCallbackId = 0;

    if (exceptionsList != null) {
      assert(
          exceptionsList.isNotEmpty, 'Expected ${exceptionsList.length} > 0');
      throw Exception('arrrgh too many errs.');
    }
  }

  /// Registers a callback object. If cancellation has already occurred, the
  /// callback will have been run by the time this method returns.
  CancellationTokenRegistration register(CancellationCallback callback,
      [Object? state]) {
    // If not canceled, register the handler; if canceled already, run the
    // callback synchronously.
    if (!isCancellationRequested) {
      if (_disposed) {
        // return CancellationTokenRegistration(id, node)
      }

      _registrations ??= Registrations(this);

      CallbackNode? node;
      var id = 0;
      if (_registrations?.freeNodeList != null) {
        node = _registrations?.freeNodeList;
        if (node != null) {
          assert(
            node.prev != null,
            'Nodes in the free list should all have a null Prev',
          );
          _registrations?.freeNodeList = node.next;

          node
            ..id = id = _registrations!._nextAvailableId++
            ..callback = callback
            ..callbackState = state
            ..next = _registrations?.callbacks;
          _registrations?.callbacks = node;
          if (node.next != null) {
            node.next?.prev = node;
          }
        }
      }

      node ??= CallbackNode(_registrations!)
        ..id = id = _registrations!._nextAvailableId++
        ..callback = callback
        ..callbackState = state
        ..next = _registrations?.callbacks;

      if (node.next != null) {
        node.next?.prev = node;
      }
      _registrations?.callbacks = node;

      assert(id != 0, 'IDs should never be the reserved value 0.');
      if (!isCancellationRequested || _registrations!.unregister(id, node)) {
        return CancellationTokenRegistration(id, node);
      }
    }

    callback.call(state);
    return CancellationTokenRegistration(0, null);
  }

  /// Throws an exception if the source has been disposed;
  void _throwIfDisposed() {
    if (_disposed) {
      throw Exception();
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

class CancellationCallbackInfo {
  final Registrations registrations;
  final CancellationCallback _callback;
  final CancellationTokenSource? _cancellationTokenSource;
  final Object? _stateForCallback;
  final int id;

  CancellationCallbackInfo({
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

class LinkedNCancellationTokenSource extends CancellationTokenSource {
  final List<CancellationTokenRegistration> _linkingRegistrations =
      <CancellationTokenRegistration>[];
  final List<CancellationToken> _tokens;

  LinkedNCancellationTokenSource(List<CancellationToken> tokens)
      : _tokens = tokens {
    for (var i = 0; i < tokens.length; i++) {
      if (_tokens[i].canBeCanceled) {
        _linkingRegistrations.add(_tokens[i].register((a) {
          (a as CancellationTokenSource)._notifyCancellation(false);
        }, this));
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

/// Set of all the registrations in the token source.
class Registrations {
  /// The associated source.
  final CancellationTokenSource source;

  /// Doubly-linked list of callbacks registered with the source. Callbacks
  /// are removed during unregistration and as they're invoked.
  CallbackNode? callbacks;

  /// Singly-linked list of free nodes that can be used for subsequent
  /// callback registrations.
  CallbackNode? freeNodeList;

  /// Every callback is assigned a unique, never-reused ID. This defines
  /// the next available ID.
  int _nextAvailableId = 1;

  /// Tracks the running callback to assist ctr.Dispose() to wait for
  /// the target callback to complete.
  // int _executingCallbackId = 0;

  /// Initializes the instance.
  Registrations(this.source);

  void _recycle(CallbackNode node) {
    // Clear out the unused node and put it on the singly-linked free list.
    // The only field we don't clear out is the associated Registrations,
    // as that's fixed throughout the node's lifetime.
    node
      ..id = 0
      ..callback = null
      ..callbackState = null
      ..prev = null
      ..next = freeNodeList;
    freeNodeList = node;
  }

  /// Unregisters a callback.
  bool unregister(int id, CallbackNode? node) {
    assert(node != null, 'Expected non-null node');
    assert(
      node!.registrations == this,
      'Expected node to come from this registrations instance',
    );
    if (id == 0) {
      return false;
    }

    if (node!.id != id) {
      return false;
    }

    if (callbacks == node) {
      assert(node.prev == null);
      callbacks = node.next;
    } else {
      assert(node.prev != null);
      node.prev!.next = node.next;
    }

    if (node.next != null) {
      node.next!.prev = node.prev;
    }

    _recycle(node);

    return true;
  }

  /// Moves all registrations to the free list.
  void unregisterAll() {
    var node = callbacks;
    callbacks = null;

    while (node != null) {
      var next = node.next;
      _recycle(node);
      node = next;
    }
  }

  void waitForCallbackToComplete() {}
}

/// All of the state associated a registered callback, in a node that's
/// part of a linked list of registered callbacks.
class CallbackNode {
  final Registrations registrations;
  CallbackNode? prev;
  CallbackNode? next;

  int id = 0;
  void Function(Object? o)?
      callback; // Action<object> or Action<object,CancellationToken>
  Object? callbackState;

  CallbackNode(this.registrations);

  void executeCallback() {
    callback?.call(callbackState);
  }
}
