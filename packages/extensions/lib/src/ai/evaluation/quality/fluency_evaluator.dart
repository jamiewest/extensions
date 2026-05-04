import 'package:extensions/annotations.dart';

import '../../chat_completion/chat_message.dart';
import '../../chat_completion/chat_response.dart';
import '../../chat_completion/chat_role.dart';
import '../evaluation_context.dart';
import 'quality_evaluator_base.dart';

/// Evaluates the fluency of an AI response — grammar, vocabulary, and
/// clarity of written communication.
///
/// Returns a [NumericMetric] named `"Fluency"` scored 1–5 (fail below 3).
/// Requires a [ChatConfiguration] with an AI model (GPT-4o recommended).
@Source(
  name: 'FluencyEvaluator.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Quality',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Evaluation.Quality/',
)
class FluencyEvaluator extends QualityEvaluatorBase {
  /// The name of the [NumericMetric] returned by this evaluator.
  static const String fluencyMetricName = 'Fluency';

  @override
  List<String> get evaluationMetricNames => const [fluencyMetricName];

  static const _systemPrompt = '''
# Instruction
## Goal
### You are an expert in evaluating the quality of a RESPONSE from an intelligent system based on provided definition and data. Your goal will involve answering the questions below using the information provided.
- **Definition**: You are given a definition of the communication trait that is being evaluated to help guide your Score.
- **Data**: Your input data include a RESPONSE.
- **Tasks**: To complete your evaluation you will be asked to evaluate the Data in different ways.
''';

  @override
  List<ChatMessage>? buildEvaluationInstructions(
    List<ChatMessage> messages,
    ChatResponse modelResponse,
    List<EvaluationContext> additionalContext,
  ) {
    final response = modelResponse.text;
    final prompt = '''
# Definition
**Fluency** refers to the quality of individual sentences in a response, measuring whether they are well-written and grammatically correct. A fluent response uses correct grammar, appropriate vocabulary, and clear sentence structure without errors.

# Ratings
## [Fluency: 1] (Incoherent)
Responses with severe grammar errors, unclear meaning, and language that makes the text almost impossible to understand.

## [Fluency: 2] (Disjointed)
Responses with frequent grammar errors, limited vocabulary, and simple sentences that reduce clarity.

## [Fluency: 3] (Mostly Fluent)
Responses with some grammar errors, adequate vocabulary, and generally understandable sentences.

## [Fluency: 4] (Fluent)
Responses with minor grammar errors, good vocabulary, and clear, well-formed sentences.

## [Fluency: 5] (Highly Fluent)
Responses with no grammar errors, sophisticated vocabulary, and complex, elegant sentences.

# Data
RESPONSE: $response

# Tasks
## Please provide your assessment Score for the previous RESPONSE based on the Definitions above.
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
