import 'ai_function.dart';
import 'delegating_ai_function.dart';

/// Represents an [AIFunction] that can be described to an AI service and
/// invoked, but for which the invoker should obtain user approval before the
/// function is actually invoked.
///
/// Remarks: This class simply augments an [AIFunction] with an indication
/// that approval is required before invocation. It does not enforce the
/// requirement for user approval; it is the responsibility of the invoker to
/// obtain that approval before invoking the function.
class ApprovalRequiredAFunction extends DelegatingAFunction {
  /// Initializes a new instance of the [ApprovalRequiredAIFunction] class.
  ///
  /// [innerFunction] The [AIFunction] represented by this instance.
  const ApprovalRequiredAFunction(AFunction innerFunction);
}
