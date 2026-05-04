import '../boolean_metric.dart';
import '../evaluator.dart';
import 'content_safety_evaluator.dart';

/// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
/// evaluate responses produced by an AI model for the presence of indirect
/// attacks such as manipulated content, intrusion and information gathering.
///
/// Remarks: Indirect attacks, also known as cross-domain prompt injected
/// attacks (XPIA), are when jailbreak attacks are injected into the context
/// of a document or source that may result in an altered, unexpected
/// behavior. Indirect attacks evaluations are broken down into three
/// subcategories: Manipulated Content: This category involves commands that
/// aim to alter or fabricate information, often to mislead or deceive.It
/// includes actions like spreading false information, altering language or
/// formatting, and hiding or emphasizing specific details.The goal is often
/// to manipulate perceptions or behaviors by controlling the flow and
/// presentation of information. Intrusion: This category encompasses commands
/// that attempt to breach systems, gain unauthorized access, or elevate
/// privileges illicitly. It includes creating backdoors, exploiting
/// vulnerabilities, and traditional jailbreaks to bypass security
/// measures.The intent is often to gain control or access sensitive data
/// without detection. Information Gathering: This category pertains to
/// accessing, deleting, or modifying data without authorization, often for
/// malicious purposes. It includes exfiltrating sensitive data, tampering
/// with system records, and removing or altering existing information. The
/// focus is on acquiring or manipulating data to exploit or compromise
/// systems and individuals. [IndirectAttackEvaluator] returns a
/// [BooleanMetric] with a value of `true` indicating the presence of an
/// indirect attack in the response, and a value of `false` indicating the
/// absence of an indirect attack. Note that [IndirectAttackEvaluator] does
/// not support evaluation of multimodal content present in the evaluated
/// responses. Images and other multimodal content present in the evaluated
/// responses will be ignored.
class IndirectAttackEvaluator extends ContentSafetyEvaluator {
  /// An [Evaluator] that utilizes the Azure AI Foundry Evaluation service to
  /// evaluate responses produced by an AI model for the presence of indirect
  /// attacks such as manipulated content, intrusion and information gathering.
  ///
  /// Remarks: Indirect attacks, also known as cross-domain prompt injected
  /// attacks (XPIA), are when jailbreak attacks are injected into the context
  /// of a document or source that may result in an altered, unexpected
  /// behavior. Indirect attacks evaluations are broken down into three
  /// subcategories: Manipulated Content: This category involves commands that
  /// aim to alter or fabricate information, often to mislead or deceive.It
  /// includes actions like spreading false information, altering language or
  /// formatting, and hiding or emphasizing specific details.The goal is often
  /// to manipulate perceptions or behaviors by controlling the flow and
  /// presentation of information. Intrusion: This category encompasses commands
  /// that attempt to breach systems, gain unauthorized access, or elevate
  /// privileges illicitly. It includes creating backdoors, exploiting
  /// vulnerabilities, and traditional jailbreaks to bypass security
  /// measures.The intent is often to gain control or access sensitive data
  /// without detection. Information Gathering: This category pertains to
  /// accessing, deleting, or modifying data without authorization, often for
  /// malicious purposes. It includes exfiltrating sensitive data, tampering
  /// with system records, and removing or altering existing information. The
  /// focus is on acquiring or manipulating data to exploit or compromise
  /// systems and individuals. [IndirectAttackEvaluator] returns a
  /// [BooleanMetric] with a value of `true` indicating the presence of an
  /// indirect attack in the response, and a value of `false` indicating the
  /// absence of an indirect attack. Note that [IndirectAttackEvaluator] does
  /// not support evaluation of multimodal content present in the evaluated
  /// responses. Images and other multimodal content present in the evaluated
  /// responses will be ignored.
  const IndirectAttackEvaluator();

  /// Gets the [Name] of the [BooleanMetric] returned by
  /// [IndirectAttackEvaluator].
  static String get indirectAttackMetricName {
    return "Indirect Attack";
  }
}
