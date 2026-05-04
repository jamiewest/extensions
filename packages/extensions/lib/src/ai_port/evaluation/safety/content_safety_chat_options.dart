import '../../abstractions/chat_completion/chat_options.dart';

class ContentSafetyChatOptions extends ChatOptions {
  ContentSafetyChatOptions({
    String? annotationTask = null,
    String? evaluatorName = null,
    ContentSafetyChatOptions? other = null,
  }) : annotationFuture = annotationTask,
       evaluatorName = evaluatorName;

  final String annotationFuture;

  final String evaluatorName;

  @override
  ChatOptions clone() {
    return contentSafetyChatOptions(this);
  }
}
