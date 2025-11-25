import '../disposable.dart';
import 'cancellation_token.dart';
import 'cancellation_token_source.dart';

class CancellationTokenRegistration implements IDisposable {
  final int _id;
  final CallbackNode? _node;

  CancellationTokenRegistration(int id, CallbackNode? node)
      : _id = id,
        _node = node;

  @override
  void dispose() {
    _node?.registrations.unregister(_id, _node);
  }

  /// Gets the [CancellationToken] with which this registration is associated.
  CancellationToken get token => _node is CallbackNode
      ? CancellationToken.fromSource(_node.registrations.source)
      : CancellationToken();

  /// Disposes of the registration and unregisters the target callback
  /// from the associated [CancellationToken].
  bool unregister() =>
      _node is CallbackNode && _node.registrations.unregister(_id, _node);

  @override
  bool operator ==(Object other) =>
      other is CancellationTokenRegistration &&
      _node == other._node &&
      _id == other._id;

  @override
  int get hashCode =>
      _node != null ? _node.hashCode ^ _id.hashCode : _id.hashCode;
}
