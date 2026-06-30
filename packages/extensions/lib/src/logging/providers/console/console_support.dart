/// Cross-platform console primitives for the console logging providers.
///
/// Selects a `dart:io`-backed implementation on platforms that have it and
/// falls back to a web-safe implementation elsewhere, keeping the console
/// logging surface compilable on web.
library;

export 'console_support_web.dart'
    if (dart.library.io) 'console_support_io.dart';
