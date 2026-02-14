import 'package:extensions/dependency_injection.dart';
import 'package:flutter/widgets.dart';

/// An InheritedWidget that provides access to the service provider.
///
/// Wrap your app with this widget to make services available to all descendants.
/// Services are registered during app initialization via the host builder.
class ServiceProviderScope extends InheritedWidget {
  const ServiceProviderScope({
    required this.services,
    required super.child,
    super.key,
  });

  /// The service provider containing all registered services.
  final ServiceProvider services;

  /// Retrieves the ServiceProviderScope from the widget tree.
  ///
  /// Throws if no ServiceProviderScope is found above this context.
  static ServiceProviderScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ServiceProviderScope>();
    assert(scope != null, 'No ServiceProviderScope found in context');
    return scope!;
  }

  /// Retrieves the ServiceProviderScope without establishing a dependency.
  ///
  /// Use this when you need the services but don't want rebuilds when
  /// the scope changes (which is rare since the scope typically doesn't change).
  static ServiceProviderScope read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ServiceProviderScope>();
    assert(scope != null, 'No ServiceProviderScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ServiceProviderScope oldWidget) {
    return services != oldWidget.services;
  }
}

/// Extension methods for convenient service access from BuildContext.
extension ServiceProviderContext on BuildContext {
  /// The service provider from the nearest ServiceProviderScope.
  ServiceProvider get services => ServiceProviderScope.of(this).services;

  /// Retrieves a required service of type T.
  ///
  /// Throws if the service is not registered.
  T getRequiredService<T extends Object>() => services.getRequiredService<T>();

  /// Retrieves an optional service of type T.
  ///
  /// Returns null if the service is not registered.
  T? getService<T extends Object>() => services.getService<T>();
}
