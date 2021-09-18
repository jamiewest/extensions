import '../shared/disposable.dart';
import 'external_scope_provider.dart';
import 'logger_provider.dart';

/// Represents a [LoggerProvider] that is able to consume
/// external scope information.
abstract class SupportExternalScope {
  /// Sets external scope information source for logger provider.
  Disposable setScopeProvider(ExternalScopeProvider scopeProvider);
}
