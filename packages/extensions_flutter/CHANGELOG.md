## 0.3.20

* Updated `extensions` dependency to `^0.3.26`.

## 0.3.19

* Updated dependency on extensions to ^0.3.25.
* Inherits OpenAI provider additions from extensions 0.3.25:
  * `OpenAIChatClient`, `OpenAIEmbeddingGenerator`, `OpenAIImageGenerator`,
    `OpenAISpeechToTextClient`, `OpenAITextToSpeechClient` — full OpenAI
    provider suite, compatible with LM Studio and other OpenAI-compatible
    local servers via `OpenAIClientOptions.endpoint`.
  * `LoggingChatClientBuilderExtensions.useLogging()` builder integration.

## 0.3.18

* Updated dependency on extensions to ^0.3.24.
* Inherits all additions and fixes from extensions 0.3.24:
  * Expanded VectorData abstractions (annotations, record schema, search options, hybrid search, legacy filter clauses).
  * `FunctionResultContent.name` field for AI function call correlation.
  * `LoggerProviderConfiguration<T>` rename (was `ILoggerProviderConfiguration<T>`).
  * `getRequiredService` error message fix.
  * `ExceptionBase.toString()` override.

## 0.3.17

* Updated dependency on extensions to ^0.3.23.
* Fixes missing `ai.dart` barrel export (extensions 0.3.23).

## 0.3.16

* Updated dependency on extensions to ^0.3.22.
* Inherits the full Microsoft.Extensions.AI port from extensions 0.3.22:
  * Core API additions: `ReasoningOptions`, `ToolCallContent`/`ToolResultContent`
    hierarchies, `AIFunctionDeclaration`, `ToolApprovalRequestContent`/`ToolApprovalResponseContent`,
    `HostedToolSearchTool`, `HostedMcpServerTool`, and `AIContentExtensions`.
  * New client pipelines: `TextToSpeechClient` and `HostedFileClient` with
    delegating, logging, and builder support.
  * OpenTelemetry middleware for all client types (`OpenTelemetryChatClient`,
    `OpenTelemetryEmbeddingGenerator`, `OpenTelemetryImageGenerator`,
    `OpenTelemetryTextToSpeechClient`).
  * Evaluation framework: NLP evaluators (BLEU, F1, GLEU), quality evaluators
    (coherence, completeness, fluency, groundedness, etc.), safety evaluators,
    and a disk-based reporting/response-caching pipeline.

## 0.3.15

* Removed an unused import in `flutter_service_collection_extensions.dart`.

## 0.3.14

* Updated dependency on extensions to ^0.3.20.
* Simplified exports by using the main `extensions.dart` barrel file instead of individual library exports.

## 0.3.13

* Updated dependency on extensions to ^0.3.19.
* Simplified hosting exports (internal functions now properly hidden in extensions package).
* Inherits code quality improvements from extensions 0.3.19.

## 0.3.12

* Updated dependency on extensions to ^0.3.18.
* Inherits all bug fixes and improvements from extensions 0.3.18:
  * Fixed file provider path handling for nested directories
  * Fixed LoggerFactory provider management
  * Improved test reliability and code quality

## 0.3.11

* Updated dependency on extensions to ^0.3.17.
* Bug fixes and improvements.

## 0.3.10

* Updated dependency on extensions to ^0.3.16.
* Inherits all new features from extensions 0.3.16:
  * Caching module (in-memory and distributed cache)
  * HTTP client logging with formatters
  * High-performance LoggerMessage API
  * Advanced console formatters
  * File system globbing
  * Diagnostics module
* Enhanced Flutter lifetime test coverage.
* Code quality improvements and analyzer warning fixes.

## 0.3.9

* Added exports for additional extensions package modules: configuration, diagnostics, file_providers, file_system_globbing, http, options, primitives, and system.
* Updated dependency on extensions to ^0.3.15.

## 0.3.8

* Hardened error handling: log full Flutter/platform errors (with stack/context) and delegate to previous handlers without swallowing crashes.
* Added cancellation support to `FlutterLifetime.waitForStart`, unregistering handlers when canceled.
* Propagate `AppLifecycleState.hidden` through `FlutterLifecycleObserver` and `FlutterApplicationLifetime`.
* Added initial tests covering error handling, lifecycle observer, and canceled startup.

## 0.3.7 

* Updates

## 0.3.6 

* More changes...

## 0.3.5

* More updates.

## 0.3.4

* More updates.

## 0.3.3

* More updates.

## 0.3.2

* Updates.

## 0.3.1

* Updates.

## 0.3.0

* Initial release.
