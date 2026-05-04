import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates the coherence of an AI response — logical organization, flow,
/// and readability.
///
/// Returns a [NumericMetric] named `"Coherence"` scored 1–5 (fail below 3).
/// Requires a [ChatConfiguration] with an AI model (GPT-4o recommended).
@Source(
  name: 'CoherenceEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class CoherenceEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String coherenceMetricName = 'Coherence';

  @override
  List<String> get evaluationMetricNames => const [coherenceMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating the quality of a RESPONSE from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
- **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
- **Data**: Your input data include a QUERY and a RESPONSE.
- **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final userRequest = messages.lastUserMessage?.text ?? '';
    final response = modelResponse.text;
    final prompt = '''
# Definition
**Coherence** refers to the logical and orderly presentation of ideas in a response, allowing the reader to easily follow and understand the writer's train of thought. A coherent answer directly addresses the question with clear connections between sentences and paragraphs, using appropriate transitions and a logical sequence of ideas.

# Ratings
## [Coherence: 1] (Incoherent Response)
**Definition:** The response lacks coherence entirely. Disjointed words or phrases with no logical connection to the question.

## [Coherence: 2] (Poorly Coherent Response)
**Definition:** Minimal coherence with fragmented sentences and limited connection to the question.

## [Coherence: 3] (Partially Coherent Response)
**Definition:** Partially addresses the question but exhibits issues in logical flow and organization.

## [Coherence: 4] (Coherent Response)
**Definition:** Coherent and effectively addresses the question with logically organized ideas and clear connections.

## [Coherence: 5] (Highly Coherent Response)
**Definition:** Exceptionally coherent, demonstrating sophisticated organization and seamless flow.

# Data
QUERY: $userRequest
RESPONSE: $response

# Tasks
## Please provide your assessment Score for the previous RESPONSE in relation to the QUERY based on the Definitions above.
- **ThoughtChain**: Think step by step. Start with "Let's think step by step:".
- **Explanation**: A very short explanation of why you think the input Data should get that Score.
- **Score**: An integer score (1–5) based on the definitions.

## Please provide your answers between the tags: <S0>your chain of thoughts</S0>, <S1>your explanation</S1>, <S2>your Score</S2>.
# Output
''';
    return [
      ChatMessage.fromText(ChatRole.system, _systemPrompt),
      ChatMessage.fromText(ChatRole.user, prompt),
    ];
  }
}
