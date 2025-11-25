// /// Formatter to convert the named format items like {NamedformatItem} to
// /// <see cref="string.Format(IFormatProvider, string, object)"/> format.
// class LogValuesFormatter {
//   final String _nullValue = '(null)';
//   final List<String> _formatDelimiters = [',', ':'];
//   late final String? _format;
//   final String _originalFormat;
//   final List<String> _valueNames = <String>[];

//   LogValuesFormatter(String format) : _originalFormat = format {
//     var sb = StringBuffer();
//     var scanIndex = 0;
//     var endIndex = format.length;

//     while (scanIndex < endIndex) {
//       var openBraceIndex = _findBraceIndex(format, '{', scanIndex, endIndex);
//       if (scanIndex == 0 && openBraceIndex == endIndex) {
//         // No holes found.
//         _format = format;
//         return;
//       }

//       var closeBraceIndex = _findBraceIndex(
//         format,
//         '}',
//         openBraceIndex,
//         endIndex,
//       );

//       if (closeBraceIndex == endIndex) {
//         sb.write(format.substring(scanIndex, endIndex - scanIndex));
//         scanIndex = endIndex;
//       } else {
//         // Format item syntax : { index[,alignment][ :formatString] }.
//         var formatDelimiterIndex = _findIndexOfAny(
//           format,
//           _formatDelimiters,
//           openBraceIndex,
//           closeBraceIndex,
//         );

//         sb
//          ..write(format.substring(scanIndex, openBraceIndex - scanIndex + 1))
//           ..write(_valueNames.length.toString());
//         _valueNames.add(format.substring(
//             openBraceIndex + 1, formatDelimiterIndex - openBraceIndex - 1));
//         sb.write(format.substring(
//           formatDelimiterIndex, closeBraceIndex - formatDelimiterIndex + 1));
//         scanIndex = closeBraceIndex + 1;
//       }
//     }

//     _format = sb.toString();
//   }

//   String get originalFormat => _originalFormat;

//   static int _findBraceIndex(
//     String format,
//     String brace,
//     int startIndex,
//     int endIndex,
//   ) {
//     // Example: {{prefix{{{Argument}}}suffix}}.
//     var braceIndex = endIndex;
//     var scanIndex = startIndex;
//     var braceOccurrenceCount = 0;

//     while (scanIndex < endIndex) {
//       if (braceOccurrenceCount > 0 && format[scanIndex] != brace) {
//         if (braceOccurrenceCount.isEven) {
//           // Even number of '{' or '}' found. Proceed search with next
//           // occurrence of '{' or '}'.
//           braceOccurrenceCount = 0;
//           braceIndex = endIndex;
//         } else {
//           // An unescaped '{' or '}' found.
//           break;
//         }
//       } else if (format[scanIndex] == brace) {
//         if (brace == '}') {
//           if (braceOccurrenceCount == 0) {
//             // For '}' pick the first occurrence.
//             braceIndex = scanIndex;
//           }
//         } else {
//           // For '{' pick the last occurrence.
//           braceIndex = scanIndex;
//         }

//         braceOccurrenceCount += 1;
//       }
//       scanIndex += 1;
//     }
//     return braceIndex;
//   }

//   static int _findIndexOfAny(
//     String format,
//     List<String> chars,
//     int startIndex,
//     int endIndex,
//   ) {
//     var findIndex = format.indexOf(
//       chars.toString(),
//       startIndex,
//     );

//     return findIndex == -1 ? endIndex : findIndex;
//   }
// }
