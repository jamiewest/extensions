import '../system/disposable.dart';
import 'system/diagnostics.dart';

import 'system/meter_options.dart';

/// A factory for creating [Meter] instances.
abstract class MeterFactory implements Disposable {
  /// Creates a new [Meter] instance.
  Meter create(MeterOptions options);
}
