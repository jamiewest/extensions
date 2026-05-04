import 'package:extensions/annotations.dart';

import 'ai_content.dart';

/// Base class for content types that represent a tool call request.
@Source(
  name: 'ToolCallContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
abstract class ToolCallContent extends AIContent {
  /// Creates a new [ToolCallContent].
  ToolCallContent({
    required this.callId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The unique identifier for this tool call.
  final String callId;
}
