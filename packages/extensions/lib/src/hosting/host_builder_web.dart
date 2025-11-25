import '../../dependency_injection.dart';
import 'host_lifetime.dart';
import 'internal/null_lifetime.dart';

void addLifetime(ServiceCollection services) =>
    services.addSingleton<HostLifetime>(
      (services) => NullLifetime(),
    );
