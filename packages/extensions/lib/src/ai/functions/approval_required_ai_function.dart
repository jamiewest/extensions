import 'package:extensions/annotations.dart';

import 'delegating_ai_function.dart';

/// An [AIFunction] that is marked as requiring user approval before
/// invocation.
///
/// This class augments an [AIFunction] with an indicator that approval
/// must be obtained before the function is called. Enforcement of the
/// approval requirement is the responsibility of the invoker (e.g.
/// [FunctionInvokingChatClient]).
@Source(
  name: 'ApprovalRequiredAIFunction.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Functions/',
)
class ApprovalRequiredAIFunction extends DelegatingAIFunction {
  /// Creates a new [ApprovalRequiredAIFunction] wrapping [innerFunction].
  ApprovalRequiredAIFunction(super.innerFunction);
}
