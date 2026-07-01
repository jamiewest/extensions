/// Resolves the platform helpers used to auto-discover a physical file provider
/// for file-based configuration.
///
/// On VM/native targets these probe the on-disk filesystem via `dart:io`; on
/// web they are no-ops so that file-based configuration remains compilable.
library;

export 'physical_provider_resolver_stub.dart'
    if (dart.library.io) 'physical_provider_resolver_io.dart';
