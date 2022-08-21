import 'package:extensions/logging.dart';

// Creates a [Logger] using the [LoggerFactory.create] static method
// using the provided `configure` function.
void main() {
  LoggerFactory.create((builder) => builder
    ..addDebug()
    ..addFilter(
      levelFilter: (level) => level.value >= LogLevel.debug.value,
    )).createLogger('MyLogger').logTrace('Hello World');
}
