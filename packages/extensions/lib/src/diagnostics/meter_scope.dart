import '../system/enum.dart';
import 'instrument_rule.dart';
import 'system/diagnostics.dart';

/// This is used by [InstrumentRule] to distinguish between meters created
/// via [Meter] constructors ([global])
/// and those created via Dependency Injection with <see cref="IMeterFactory.Create(MeterOptions)"/> (<see cref="Local"/>)."/>.
enum MeterScope with EnumFlags {
  /// No scope is specified. This should not be used.
  none,

  /// Indicates [Meter] instances created via [Meter] constructors.
  global,

  /// Indicates [Meter] instances created via Dependency Injection with
  /// [MeterFactory.Create(MeterOptions)].
  local,
}
