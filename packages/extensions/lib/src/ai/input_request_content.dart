import 'package:extensions/annotations.dart';

import 'ai_content.dart';

/// Represents a request for input from the user or application.
///
/// The [requestId] correlates this request with its [InputResponseContent].
@Source(
  name: 'InputRequestContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class InputRequestContent extends AIContent {
  /// Creates a new [InputRequestContent].
  InputRequestContent({
    required this.requestId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// Unique identifier correlating this request with its response.
  final String requestId;
}
