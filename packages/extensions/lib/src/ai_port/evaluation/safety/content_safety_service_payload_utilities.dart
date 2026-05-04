import '../../abstractions/chat_completion/chat_message.dart';
import '../../abstractions/chat_completion/chat_role.dart';
import '../../abstractions/contents/data_content.dart';
import '../../abstractions/contents/text_content.dart';
import '../../abstractions/contents/uri_content.dart';
import '../evaluation_diagnostic.dart';
import 'content_safety_service_payload_format.dart';
import 'content_safety_service_payload_strategy.dart';

class ContentSafetyServicePayloadUtilities {
  ContentSafetyServicePayloadUtilities();

  static stringpayloadReadOnlyListEvaluationDiagnosticdiagnostics getPayload(
    ContentSafetyServicePayloadFormat payloadFormat,
    Iterable<ChatMessage> conversation,
    String annotationTask,
    String evaluatorName,
    {Iterable<String?>? perTurnContext, Iterable<String>? metricNames, CancellationToken? cancellationToken, },
  ) {
    return payloadFormat switch
            {
                ContentSafetyServicePayloadFormat.humanSystem =>
                    getUserTextListPayloadWithEmbeddedXml(
                        conversation,
                        annotationTask,
                        evaluatorName,
                        perTurnContext,
                        metricNames,
                        cancellationToken: cancellationToken),

                ContentSafetyServicePayloadFormat.questionAnswer =>
                    getUserTextListPayloadWithEmbeddedJson(
                        conversation,
                        annotationTask,
                        evaluatorName,
                        perTurnContext,
                        metricNames,
                        cancellationToken: cancellationToken),

                ContentSafetyServicePayloadFormat.queryResponse =>
                    getUserTextListPayloadWithEmbeddedJson(
                        conversation,
                        annotationTask,
                        evaluatorName,
                        perTurnContext,
                        metricNames,
                        questionPropertyName: "query",
                        answerPropertyName: "response",
                        cancellationToken: cancellationToken),

                ContentSafetyServicePayloadFormat.contextCompletion =>
                    getUserTextListPayloadWithEmbeddedJson(
                        conversation,
                        annotationTask,
                        evaluatorName,
                        perTurnContext,
                        metricNames,
                        questionPropertyName: "context",
                        answerPropertyName: "completion",
                        cancellationToken: cancellationToken),

                ContentSafetyServicePayloadFormat.conversation =>
                    getConversationPayload(
                        conversation,
                        annotationTask,
                        evaluatorName,
                        perTurnContext,
                        metricNames,
                        cancellationToken: cancellationToken),

                (_) => throw notSupportedException('The payload kind '${payloadFormat}' is! supported.'),
            };
  }

  static stringpayloadReadOnlyListEvaluationDiagnosticdiagnostics getUserTextListPayloadWithEmbeddedXml(
    Iterable<ChatMessage> conversation,
    String annotationTask,
    String evaluatorName,
    {Iterable<String?>? perTurnContext, Iterable<String>? metricNames, String? questionElementName, String? answerElementName, String? contextElementName, ContentSafetyServicePayloadStrategy? strategy, CancellationToken? cancellationToken, },
  ) {
    List<Dictionary<string, ChatMessage>> turns;
    List<string?>? normalizedPerTurnContext;
    List<EvaluationDiagnostic>? diagnostics;
    (turns, normalizedPerTurnContext, diagnostics, _) =
            preProcessConversation(
                conversation,
                evaluatorName,
                perTurnContext,
                returnLastTurnOnly: strategy is ContentSafetyServicePayloadStrategy.annotateLastTurn,
                cancellationToken: cancellationToken);
    var userTextListItems = turns.select(
                (turn, index) =>
                {
                    cancellationToken.throwIfCancellationRequested();

                    List<XElement> item = [];

                    if (turn.tryGetValue("question", out ChatMessage? question))
                    {
                        item.add(xElement(questionElementName, question.text));
      }

                    if (turn.tryGetValue("answer", out ChatMessage? answer))
                    {
                        item.add(xElement(answerElementName, answer.text));
      }

                    if (normalizedPerTurnContext != null && normalizedPerTurnContext.any())
                    {
                        item.add(xElement(contextElementName, normalizedPerTurnContext[index]));
      }

                    return item;
                });
    var userTextListStrings = userTextListItems.select((item) => string.join(string.empty, item.select((e) => e.toString())));
    if (strategy is ContentSafetyServicePayloadStrategy.annotateConversation) {
      // Combine all turns into a single string. In this case, the service will produce a single annotation
            // result for the entire conversation.
            userTextListStrings = [string.join(Environment.newLine, userTextListStrings)];
    } else {}
    var payload = jsonObject();
    if (metricNames != null && metricNames.any()) {
      payload["MetricList"] = jsonArray([.. metricNames]);
    }
    return (payload.toJsonString(), diagnostics);
  }

  static stringpayloadReadOnlyListEvaluationDiagnosticdiagnostics getUserTextListPayloadWithEmbeddedJson(
    Iterable<ChatMessage> conversation,
    String annotationTask,
    String evaluatorName,
    {Iterable<String?>? perTurnContext, Iterable<String>? metricNames, String? questionPropertyName, String? answerPropertyName, String? contextPropertyName, ContentSafetyServicePayloadStrategy? strategy, CancellationToken? cancellationToken, },
  ) {
    if (strategy is ContentSafetyServicePayloadStrategy.annotateConversation) {
      throw notSupportedException(
                '${nameof(GetUserTextListPayloadWithEmbeddedJson)} does not support the ${strategy} ${nameof(ContentSafetyServicePayloadStrategy)}.');
    }
    List<Dictionary<string, ChatMessage>> turns;
    List<string?>? normalizedPerTurnContext;
    List<EvaluationDiagnostic>? diagnostics;
    (turns, normalizedPerTurnContext, diagnostics, _) =
            preProcessConversation(
                conversation,
                evaluatorName,
                perTurnContext,
                returnLastTurnOnly: strategy is ContentSafetyServicePayloadStrategy.annotateLastTurn,
                cancellationToken: cancellationToken);
    var userTextListItems = turns.select(
                (turn, index) =>
                {
                    cancellationToken.throwIfCancellationRequested();

                    var item = jsonObject();

                    if (turn.tryGetValue("question", out ChatMessage? question))
                    {
                        item[questionPropertyName] = question.text;
      }

                    if (turn.tryGetValue("answer", out ChatMessage? answer))
                    {
                        item[answerPropertyName] = answer.text;
      }

                    if (normalizedPerTurnContext != null && normalizedPerTurnContext.any())
                    {
                        item[contextPropertyName] = normalizedPerTurnContext[index];
      }

                    return item;
                });
    var userTextListStrings = userTextListItems.select((item) => item.toJsonString());
    var payload = jsonObject();
    if (metricNames != null && metricNames.any()) {
      payload["MetricList"] = jsonArray([.. metricNames]);
    }
    return (payload.toJsonString(), diagnostics);
  }

  static stringpayloadReadOnlyListEvaluationDiagnosticdiagnostics getConversationPayload(
    Iterable<ChatMessage> conversation,
    String annotationTask,
    String evaluatorName,
    {Iterable<String?>? perTurnContext, Iterable<String>? metricNames, ContentSafetyServicePayloadStrategy? strategy, CancellationToken? cancellationToken, },
  ) {
    if (strategy is ContentSafetyServicePayloadStrategy.annotateEachTurn) {
      throw notSupportedException(
                '${nameof(GetConversationPayload)} does not support the ${strategy} ${nameof(ContentSafetyServicePayloadStrategy)}.');
    }
    List<Dictionary<string, ChatMessage>> turns;
    List<string?>? normalizedPerTurnContext;
    List<EvaluationDiagnostic>? diagnostics;
    String contentType;
    (turns, normalizedPerTurnContext, diagnostics, contentType) =
            preProcessConversation(
                conversation,
                evaluatorName,
                perTurnContext,
                returnLastTurnOnly: strategy is ContentSafetyServicePayloadStrategy.annotateLastTurn,
                areImagesSupported: true,
                cancellationToken);
    /* TODO: unsupported node kind "unknown" */
    // IEnumerable<JsonObject> GetMessages(Dictionary<string, ChatMessage> turn, int turnIndex)
    //         {
      //             cancellationToken.ThrowIfCancellationRequested();
      //
      //             if (turn.TryGetValue("question", out ChatMessage? question))
      //             {
        //                 IEnumerable<JsonObject> contents = GetContents(question);
        //
        //                 yield return new JsonObject
        //                 {
          //                     ["role"] = "user",
          //                     ["content"] = new JsonArray([.. contents])
          //                 };
        //             }
      //
      //             if (turn.TryGetValue("answer", out ChatMessage? answer))
      //             {
        //                 IEnumerable<JsonObject> contents = GetContents(answer);
        //
        //                 if (normalizedPerTurnContext is not null &&
        //                     normalizedPerTurnContext.Any() &&
        //                     normalizedPerTurnContext[turnIndex] is string context)
        //                 {
          //                     yield return new JsonObject
          //                     {
            //                         ["role"] = "assistant",
            //                         ["content"] = new JsonArray([.. contents]),
            //                         ["context"] = context
            //                     };
          //                 }
        //                 else
        //                 {
          //                     yield return new JsonObject
          //                     {
            //                         ["role"] = "assistant",
            //                         ["content"] = new JsonArray([.. contents]),
            //                     };
          //                 }
        //             }
      //
      //             IEnumerable<JsonObject> GetContents(ChatMessage message)
      //             {
        //                 foreach (AIContent content in message.Contents)
        //                 {
          //                     cancellationToken.ThrowIfCancellationRequested();
          //
          //                     if (content is TextContent textContent)
          //                     {
            //                         yield return new JsonObject
            //                         {
              //                             ["type"] = "text",
              //                             ["text"] = textContent.Text
              //                         };
            //                     }
          //                     else if (content is UriContent uriContent && uriContent.HasTopLevelMediaType("image"))
          //                     {
            //                         yield return new JsonObject
            //                         {
              //                             ["type"] = "image_url",
              //                             ["image_url"] =
              //                                 new JsonObject
              //                                 {
                //                                     ["url"] = uriContent.Uri.AbsoluteUri
                //                                 }
              //                         };
            //                     }
          //                     else if (content is DataContent dataContent && dataContent.HasTopLevelMediaType("image"))
          //                     {
            //                         yield return new JsonObject
            //                         {
              //                             ["type"] = "image_url",
              //                             ["image_url"] =
              //                                 new JsonObject
              //                                 {
                //                                     ["url"] = dataContent.Uri
                //                                 }
              //                         };
            //                     }
          //                 }
        //             }
      //         }
    var payload = jsonObject()),
                ["AnnotationTask"] = annotationTask,
            };
  if (metricNames != null && metricNames.any()) {
    payload["MetricList"] = jsonArray([.. metricNames]);
  }

  return (payload.toJsonString(), diagnostics);
}
static ListDictionarystringChatMessageturnsListstringnormalizedPerTurnContextListEvaluationDiagnosticdiagnosticsstringcontentType preProcessConversation(
  Iterable<ChatMessage> conversation,
  String evaluatorName,
  {Iterable<String?>? perTurnContext, bool? returnLastTurnOnly, bool? areImagesSupported, CancellationToken? cancellationToken, },
) {
var turns = [];
var currentTurn = [];
var normalizedPerTurnContext = perTurnContext == null || !perTurnContext.any() ? null : [.. perTurnContext];
var currentTurnIndex = 0;
var ignoredMessageCount = 0;
var incompleteTurnCount = 0;
/* TODO: unsupported node kind "unknown" */
// void StartNewTurn()
//         {
//             if (!currentTurn.ContainsKey("question") || !currentTurn.ContainsKey("answer"))
//             {
//                 ++incompleteTurnCount;
//             }
//
//             turns.Add(currentTurn);
//             currentTurn = [];
//             ++currentTurnIndex;
//         }
for (final message in conversation) {
  cancellationToken.throwIfCancellationRequested();
  if (message.role == ChatRole.user) {
    if (currentTurn.containsKey("question")) {
      startNewTurn();
    }
    currentTurn["question"] = message;
  } else if (message.role == ChatRole.assistant) {
    currentTurn["answer"] = message;
    startNewTurn();
  } else {
    // System prompts are currently not supported.
                ignoredMessageCount++;
  }
}
if (returnLastTurnOnly) {
  turns.removeRange(index: 0, count: turns.count - 1);
}
var imagesCount = 0;
var unsupportedContentCount = 0;
/* TODO: unsupported node kind "unknown" */
// void ValidateContents(ChatMessage message)
//         {
//             foreach (AIContent content in message.Contents)
//             {
//                 cancellationToken.ThrowIfCancellationRequested();
//
//                 if (areImagesSupported)
//                 {
//                     if (content.IsImageWithSupportedFormat())
//                     {
//                         ++imagesCount;
//                     }
//                     else if (!content.IsTextOrUsage())
//                     {
//                         ++unsupportedContentCount;
//                     }
//                 }
//                 else if (!content.IsTextOrUsage())
//                 {
//                     ++unsupportedContentCount;
//                 }
//             }
//         }
for (final turn in turns) {
  cancellationToken.throwIfCancellationRequested();
  for (final message in turn.values) {
    cancellationToken.throwIfCancellationRequested();
    validateContents(message);
  }
}
var diagnostics = null;
if (ignoredMessageCount > 0) {
  diagnostics = [
                EvaluationDiagnostic.warning(
                    'The supplied conversation contained ${ignoredMessageCount} messages with unsupported roles. ' +
                    '${evaluatorName} only considers messages with role '${ChatRole.user}' and '${ChatRole.assistant}'. ' +
                    'The unsupported messages (which may include messages with role '${ChatRole.system}' and '${ChatRole.tool}') were ignored.')];
}
if (incompleteTurnCount > 0) {
  diagnostics ??= [];
  diagnostics.add(
                EvaluationDiagnostic.warning(
                    'The supplied conversation contained ${incompleteTurnCount} incomplete turns. ' +
                    'These turns were either missing a message with role '${ChatRole.user}' or '${ChatRole.assistant}'. ' +
                    'This may indicate that the supplied conversation was not well-formed and may result in inaccurate evaluation results.'));
}
if (unsupportedContentCount > 0) {
  diagnostics ??= [];
  if (areImagesSupported) {
    diagnostics.add(
                    EvaluationDiagnostic.warning(
                        'The supplied conversation contained ${unsupportedContentCount} instances of unsupported content within messages. ' +
                        'The current evaluation being performed by ${evaluatorName} only supports content of type '${nameof(TextContent)}', '${nameof(UriContent)}' and '${nameof(DataContent)}'. ' +
                        'For '${nameof(UriContent)}' and '${nameof(DataContent)}', only content with media type 'image/png', 'image/jpeg' and 'image/gif' are supported. ' +
                        'The unsupported contents were ignored for this evaluation.'));
  } else {
    diagnostics.add(
                    EvaluationDiagnostic.warning(
                        'The supplied conversation contained ${unsupportedContentCount} instances of unsupported content within messages. ' +
                        'The current evaluation being performed by ${evaluatorName} only supports content of type '${nameof(TextContent)}'. ' +
                        'The unsupported contents were ignored for this evaluation.'));
  }
}
if (normalizedPerTurnContext != null && normalizedPerTurnContext.any()) {
  if (normalizedPerTurnContext.count > turns.count) {
    var ignoredContextCount = normalizedPerTurnContext.count - turns.count;
    diagnostics ??= [];
    diagnostics.add(
                    EvaluationDiagnostic.warning(
                        'The supplied conversation contained ${turns.count} turns. ' +
                        'However, context for ${normalizedPerTurnContext.count} turns were supplied as part of the context collection. ' +
                        'The initial ${ignoredContextCount} items from the context collection were ignored. ' +
                        'Only the last ${turns.count} items from the context collection were used.'));
    normalizedPerTurnContext.removeRange(0, ignoredContextCount);
  } else if (normalizedPerTurnContext.count < turns.count) {
    var missingContextCount = turns.count - normalizedPerTurnContext.count;
    diagnostics ??= [];
    diagnostics.add(
                    EvaluationDiagnostic.warning(
                        'The supplied conversation contained ${turns.count} turns. ' +
                        'However, context for only ${normalizedPerTurnContext.count} turns were supplied as part of the context collection. ' +
                        'The initial ${missingContextCount} turns in the conversations were evaluated without any context. ' +
                        'The supplied items in the context collection were applied to the last ${normalizedPerTurnContext.count} turns.'));
    normalizedPerTurnContext.insertRange(0, Enumerable.repeat<String?>(null, missingContextCount));
  }
}
var contentType = areImagesSupported && imagesCount > 0 ? "image" : "text";
return (turns, normalizedPerTurnContext, diagnostics, contentType);
 }
 }
