import '../exceptions/operation_cancelled_exception.dart';
import 'cancellation_token_registration.dart';
import 'cancellation_token_source.dart';

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
  factory CancellationToken([bool? canceled]) {
    if (canceled == null || canceled == false) {
      return const CancellationToken._();
    }

    return CancellationToken._(CancellationTokenSource.canceledSource);
  }

  factory CancellationToken.fromSource(CancellationTokenSource? source) =>
      CancellationToken._(source);

  /// Returns an empty CancellationToken value.
  ///
  /// This property indicates whether cancellation has been requested for this
  /// token, either through the token initially being constructed in a canceled
  /// state, or through calling `cancel` on the token's associated
  /// [CancellationTokenSource].
  static CancellationToken get none => CancellationToken();

  /// Gets whether cancellation has been requested for this token.
  bool get isCancellationRequested =>
      _source != null && _source.isCancellationRequested;

  /// Gets whether this token is capable of being in the canceled state.
  ///
  /// If CanBeCanceled returns false, it is guaranteed that the token will
  /// never transition into a canceled state, meaning that
  /// `isCancellationRequested` will never return true.
  bool get canBeCanceled => _source != null;

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

  /// Throws a [OperationCanceledException] if
  /// this token has had cancellation requested.
  void _throwOperationCanceledException() {
    /// TODO: FIX THIS
    //throw OperationCanceledException(cancellationToken: this);
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
      (_source ?? CancellationTokenSource.neverCanceledSource).hashCode;
}

typedef CallbackRegistration = void Function(Object? state);

typedef CancellationCallback = void Function(Object? state);
