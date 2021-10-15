// import '../shared/disposable.dart';
// import 'activity_tracking_options.dart';
// import 'external_scope_provider.dart';

// class LoggerFactoryScopeProvider implements ExternalScopeProvider {
//   final ActivityTrackingOptions _activityTrackingOptions;

//   LoggerFactoryScopeProvider(ActivityTrackingOptions activityTrackingOptions)
//       : _activityTrackingOptions = activityTrackingOptions;

//   @override
//   void forEachScope<TState>(ScopeCallback<TState> callback, TState state) {
//     // void report(_Scope? current) {
//     //   if (current == null) {
//     //     return;
//     //   }
//     //   report(current.parent);
//     //   callback(current.state, state);
//     // }

//     // if (_activityTrackingOptions != ActivityTrackingOptions.none) {
//     //   var activity = ActivityTrackingOptions.
//     // }
//   }

//   @override
//   Disposable push(Object? state) {
//     // TODO: implement push
//     throw UnimplementedError();
//   }
// }

// class _Scope extends Disposable {
//   final LoggerFactoryScopeProvider _provider;
//   bool _isDisposed;
//   final _Scope _parent;
//   final Object? _state;

//   _Scope(
//     LoggerFactoryScopeProvider provider,
//     Object state,
//     _Scope parent,
//   )   : _provider = provider,
//         _isDisposed = false,
//         _state = state,
//         _parent = parent;

//   _Scope get parent => _parent;

//   Object? get state => _state;

//   @override
//   String toString() => _state.toString();

//   @override
//   void dispose() {
//     if (!_isDisposed) {
//       //_provider._currentScope.value = parent;
//       _isDisposed = true;
//     }
//   }
// }
