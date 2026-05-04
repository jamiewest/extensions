import 'package:extensions/annotations.dart';

import 'ai_content.dart';

/// Base class for content types that represent the result of a tool call.
@Source(
  name: 'ToolResultContent.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Contents/',
)
abstract class ToolResultContent extends AIContent {
  /// Creates a new [ToolResultContent].
  ToolResultContent({
    required this.callId,
    super.rawRepresentation,
    super.additionalProperties,
  });

  /// The ID of the [ToolCallContent] this result corresponds to.
  final String callId;
}
