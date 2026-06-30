/// Writes a single line to the console.
void writeConsoleLine(String message) => print(message);

/// Whether the console supports ANSI escape sequences.
///
/// Always `false` on platforms without `dart:io`.
bool get consoleSupportsAnsi => false;
