import 'package:extensions/logging.dart';

// Creates a [Logger] using the [LoggerFactory.create] static method
// using the provided `configure` function.
void main() {
  LoggerFactory.create(
    (builder) => builder
      ..addDebug()
      ..setMinimumLevel(LogLevel.debug),
  ).createLogger('MyLogger').logDebug('Hello World');
}
