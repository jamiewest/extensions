import 'package:extensions/annotations.dart';

import 'ai_content.dart';

/// Represents the response to an [InputRequestContent].
///
/// The [requestId] correlates this response with its originating request.
@Source(
  name: 'InputResponseContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
class InputResponseContent extends AIContent {
  /// Creates a new [InputResponseContent].
  InputResponseContent({
    required this.requestId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// Unique identifier correlating this response with its request.
  final String requestId;
}
