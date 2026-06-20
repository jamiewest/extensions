import 'package:extensions/annotations.dart';

import '../chat_completion/chat_tool_mode.dart';
import '../speech_to_text/transcription_options.dart';
import '../tools/ai_tool.dart';
import 'realtime_audio_format.dart';
import 'realtime_session_kind.dart';
import 'voice_activity_detection_options.dart';

/// Represents options for configuring a real-time session.
///
/// This is an experimental feature.
@Source(
  name: 'RealtimeSessionOptions.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI.Abstractions/Realtime/',
  commit: '2e537166e4231e50cceb66832b9dfd1382e24d1b',
)
class RealtimeSessionOptions {
  /// Creates a new [RealtimeSessionOptions].
  RealtimeSessionOptions({
    this.sessionKind = RealtimeSessionKind.conversation,
    this.model,
    this.inputAudioFormat,
    this.transcriptionOptions,
    this.outputAudioFormat,
    this.voice,
    this.instructions,
    this.maxOutputTokens,
    this.outputModalities,
    this.toolMode,
    this.tools,
    this.voiceActivityDetection,
    this.rawRepresentationFactory,
  });

  /// The session kind.
  RealtimeSessionKind sessionKind;

  /// The model name to use for the session.
  String? model;

  /// The input audio format for the session.
  RealtimeAudioFormat? inputAudioFormat;

  /// The transcription options for the session.
  TranscriptionOptions? transcriptionOptions;

  /// The output audio format for the session.
  RealtimeAudioFormat? outputAudioFormat;

  /// The output voice for the session.
  String? voice;

  /// The default system instructions for the session.
  String? instructions;

  /// The maximum number of response tokens for the session.
  int? maxOutputTokens;

  /// The output modalities for the response, such as "text" or "audio".
  ///
  /// If null, then default conversation modalities will be used.
  List<String>? outputModalities;

  /// The tool choice mode for the session.
  ChatToolMode? toolMode;

  /// The AI tools available for generating the response.
  List<AITool>? tools;

  /// The voice activity detection (VAD) options for the session.
  ///
  /// When null, the provider's default VAD behavior is used.
  VoiceActivityDetectionOptions? voiceActivityDetection;

  /// A callback responsible for creating the raw representation of the session
  /// options from an underlying implementation.
  Object? Function()? rawRepresentationFactory;

  /// Creates a deep copy of this [RealtimeSessionOptions].
  RealtimeSessionOptions clone() => RealtimeSessionOptions(
        sessionKind: sessionKind,
        model: model,
        inputAudioFormat: inputAudioFormat,
        transcriptionOptions: transcriptionOptions,
        outputAudioFormat: outputAudioFormat,
        voice: voice,
        instructions: instructions,
        maxOutputTokens: maxOutputTokens,
        outputModalities: outputModalities != null
            ? List<String>.of(outputModalities!)
            : null,
        toolMode: toolMode,
        tools: tools != null ? List<AITool>.of(tools!) : null,
        voiceActivityDetection: voiceActivityDetection,
        rawRepresentationFactory: rawRepresentationFactory,
      );
}
