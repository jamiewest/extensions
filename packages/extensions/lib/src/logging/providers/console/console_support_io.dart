import 'dart:io';

/// Writes a single line to standard output.
void writeConsoleLine(String message) => stdout.writeln(message);

/// Whether the current standard output supports ANSI escape sequences.
bool get consoleSupportsAnsi => stdout.supportsAnsiEscapes;
