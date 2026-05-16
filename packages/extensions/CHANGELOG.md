## 0.3.22

* **AI — Microsoft.Extensions.AI port (Phases 1–4):**

  * **Phase 1 — Core API gaps:**
    * Added `ReasoningOptions`, `ReasoningEffort`, and `ReasoningOutput` types for model reasoning control
    * Added `allowBackgroundResponses` and `rawRepresentationFactory` to `ChatOptions`
    * Replaced merged content types with proper call/result pairs: `CodeInterpreterToolCallContent` / `CodeInterpreterToolResultContent`, `ImageGenerationToolCallContent` / `ImageGenerationToolResultContent`, `McpServerToolCallContent` / `McpServerToolResultContent`, `InputRequestContent` / `InputResponseContent`, `WebSearchToolCallContent` / `WebSearchToolResultContent`
    * Added abstract `ToolCallContent` and `ToolResultContent` base classes
    * Added `ToolApprovalRequestContent` / `ToolApprovalResponseContent` for user-in-the-loop approval flows
    * Added `AIFunctionDeclaration`, `AIFunctionFactoryOptions`, `DelegatingAIFunctionDeclaration`, `ApprovalRequiredAIFunction`
    * Added `HostedToolSearchTool` and `HostedMcpServerTool` approval mode hierarchy (`AlwaysRequire`, `NeverRequire`, `RequireSpecific`)
    * Added `AIContentExtensions` with `firstOfType<T>()` and `allOfType<T>()` helpers
    * Added `AutoChatToolMode` to the public API

  * **Phase 2 — New client types:**
    * Added `TextToSpeechClient` pipeline: `TextToSpeechClient`, `TextToSpeechOptions`, `TextToSpeechResponse`, `TextToSpeechResponseUpdate`, `TextToSpeechClientMetadata`, `DelegatingTextToSpeechClient`, `ConfigureOptionsTextToSpeechClient`, `LoggingTextToSpeechClient`, `TextToSpeechClientBuilder`
    * Added `HostedFileClient` pipeline: `HostedFileClient`, `DelegatingHostedFileClient`, `LoggingHostedFileClient`, `HostedFileClientBuilder`

  * **Phase 3 — OpenTelemetry middleware:**
    * Added `OpenTelemetryChatClient`, `OpenTelemetryEmbeddingGenerator`, `OpenTelemetryImageGenerator`, `OpenTelemetryTextToSpeechClient` decorators
    * Added `useOpenTelemetry()` builder extension for each client type
    * Added `OpenTelemetryConsts` with span and attribute name constants

  * **Phase 4 — Evaluation framework:**
    * **NLP evaluators:** `BleuEvaluator`, `F1Evaluator`, `GleuEvaluator` with supporting algorithms (`BleuAlgorithm`, `F1Algorithm`, `GleuAlgorithm`, `NGram`, `SimpleWordTokenizer`)
    * **Quality evaluators:** `CoherenceEvaluator`, `CompletenessEvaluator`, `EquivalenceEvaluator`, `FluencyEvaluator`, `GroundednessEvaluator`, `IntentResolutionEvaluator`, `RelevanceTruthAndCompletenessEvaluator`, `RetrievalEvaluator`, `TaskAdherenceEvaluator`, `ToolCallAccuracyEvaluator`
    * **Safety evaluators:** `CodeVulnerabilityEvaluator`, `ContentHarmEvaluator`, `HateAndUnfairnessEvaluator`, `IndirectAttackEvaluator`, `ProtectedMaterialEvaluator`, `SelfHarmEvaluator`, `SexualEvaluator`, `ViolenceEvaluator`, `UngroundedAttributesEvaluator`, `GroundednessProEvaluator`
    * **Reporting:** `ScenarioRun`, `ReportingConfiguration`, `ResponseCachingChatClient`, disk-based `ResponseCache`, `ResultStore`, and `ReportingConfiguration` factory

* **VectorData — Microsoft.Extensions.VectorData.Abstractions port:**
  * Added `VectorStore`, `VectorStoreCollection<TKey, TRecord>`, and `VectorStoreRecordCollection<TKey, TRecord>` abstractions
  * Added `VectorStoreFilter` sealed hierarchy: `EqualToVectorStoreFilter`, `AnyTagEqualToVectorStoreFilter`, `AndVectorStoreFilter`, `OrVectorStoreFilter`
  * Added record definition types: `VectorStoreRecordDefinition`, `VectorStoreRecordDataProperty`, `VectorStoreRecordKeyProperty`, `VectorStoreRecordVectorProperty`
  * Added attribute annotations: `VectorStoreRecordData`, `VectorStoreRecordKey`, `VectorStoreRecordVector`
  * Added options types for all collection operations with distinct method names (`getAsync`/`getBatchAsync`/`getFilteredAsync`, `upsertAsync`/`upsertBatchAsync`, `deleteAsync`/`deleteBatchAsync`)
  * Added `OrderByClause` with `ascending(field)` / `descending(field)` factory methods
  * Exported from `package:extensions/vector_data.dart` and included in `package:extensions/extensions.dart`

* **Bug Fix — Dependency Injection:**
  * Fixed `getKeyedServices<T>(key)` always returning empty or throwing a `TypeError`. The method now correctly requests `Iterable<T>` from the provider (mirroring the non-keyed `getServices<T>()` and the C# `GetKeyedServices<T>()` implementation), which routes through `CallSiteFactory.tryCreateIterable()` and aggregates all registrations under the given key.
  * `getKeyedServicesFromType(Type, key)` now throws `UnsupportedError` with a clear message (Dart cannot construct `Iterable<T>` from a runtime `Type`; use `getKeyedServices<T>()` instead).

## 0.3.21

* Updates.

## 0.3.20

* Updates.

## 0.3.19

* **Code Quality:**
  * Improved export visibility in hosting libraries by hiding internal implementation functions (`addCommandLineConfig`, `addDefaultServices`, `applyDefaultAppConfiguration`, `createDefaultServiceProviderOptions`)
  * Code formatting improvements in AI logging clients (line length fixes)
  * Improved import naming conventions in `HostApplicationBuilder` to follow Dart style guidelines
  * Fixed documentation reference in `FunctionInvocationContext`

## 0.3.18

* **Bug Fixes:**
  * Fixed `PhysicalFileProvider.getFileInfo()` and `getDirectoryContents()` incorrectly handling nested directory paths by removing the first path separator anywhere in the path instead of only at the beginning
  * Fixed `LoggerFactory.addProvider()` throwing `RangeError` when adding providers after loggers were already created due to incorrect list index assignment
  * Improved `_isUnderneathRoot()` validation to prevent false positive matches on paths with common prefixes
  * Fixed file polling tests to account for file system timestamp granularity (1-second precision)

* **Code Quality:**
  * Fixed all analyzer issues (import ordering, naming conventions, line length, unused imports/variables)
  * Renamed `ArgumentOutOfRangeException.ThrowNegative()` and `ThrowNegativeOrZero()` to follow Dart naming conventions (lowerCamelCase)
  * Improved test reliability by ensuring proper timing for file system timestamp changes
  * Disabled `cascade_invocations` lint rule to reduce noise in test files

* **Test Improvements:**
  * Fixed and re-enabled 3 previously skipped tests
  * All 508 tests now pass with improved timing reliability
  * Added better handling for platform-specific file system behavior

## 0.3.17

* Bug fixes and improvements.

## 0.3.16

* **Major Feature Additions:**
  * Added comprehensive **Caching** module with in-memory and distributed cache support
  * Added **HTTP Client Logging** with configurable formatters and redaction
  * Added high-performance **LoggerMessage** API for zero-allocation logging
  * Added **Typed Logger** support (`Logger<T>`)
  * Added advanced **Console Formatters** (Simple, JSON, Systemd)
  * Added **File System Globbing** with advanced pattern matching
  * Added **Diagnostics** module for activity tracking and metrics

* **Caching:**
  * New `MemoryCache` with size limits, priorities, and eviction policies
  * `DistributedCache` abstraction with in-memory implementation
  * Post-eviction callbacks and cache statistics
  * Sliding and absolute expiration support
  * Examples: [example_caching.dart](packages/extensions/example/example_caching.dart)

* **Logging:**
  * High-performance `LoggerMessage.define` API for cached log delegates
  * `BufferedLogRecord` for structured logging scenarios
  * `NullTypedLogger<T>` for testing and no-op scenarios
  * Console formatters with customizable output (simple, JSON, systemd)
  * Color support and timestamp formatting
  * Examples: [example_advanced_logging.dart](packages/extensions/example/example_advanced_logging.dart), [example_console_formatters.dart](packages/extensions/example/example_console_formatters.dart)

* **HTTP:**
  * HTTP client logging with request/response tracking
  * Header redaction for sensitive data
  * Configurable handler lifetime
  * Scoped logging integration
  * Example: [example_http_client_logging.dart](packages/extensions/example/example_http_client_logging.dart)

* **File Providers:**
  * Enhanced polling change tokens with debouncing
  * Physical file provider options
  * Improved file watching reliability
  * Example: [example_file_providers.dart](packages/extensions/example/example_file_providers.dart)

* **File System Globbing:**
  * Advanced pattern matching with multiple patterns
  * Exclusion support
  * Case-sensitive/insensitive matching
  * Example: [example_file_system_globbing.dart](packages/extensions/example/example_file_system_globbing.dart)

* **Diagnostics:**
  * Activity tracking and propagation
  * Diagnostic listeners
  * Example: [example_diagnostics.dart](packages/extensions/example/example_diagnostics.dart)

* **Testing:**
  * Added 1000+ new test cases across all modules
  * Comprehensive test coverage for caching, logging, and primitives

* **Code Quality:**
  * Fixed all analyzer warnings and errors
  * Improved type inference in examples
  * Removed unused imports and variables

* **Breaking Changes:**
  * None - all additions are backward compatible

## 0.3.15

* Changed logging scope for lifetime messages and added additional tests.

## 0.3.14

* Updates.

## 0.3.13

* Bug fixes.

## 0.3.12

* Updates.

## 0.3.11

* Exported CancellationTokenRegistration.

## 0.3.10

* Added const constructor to NullLoggerFactory.

## 0.3.9

* Exported NullLogger, NullLoggerFactory, and CancellationTokenSource. Changed Logger.logError to not require and exception.

## 0.3.8

* Bug fixes and updates.

## 0.3.7

* Bug fixes and updates.

## 0.3.6

* Downgrading `async` package.

## 0.3.5

* Bug fixes and updates.

## 0.3.4

* Bug fixes and updates.

## 0.3.3

* Bug fixes and updates.

## 0.3.2

* Bug fixes and updates.

## 0.3.1

* Bug fixes and updates.

## 0.3.0

- Initial version
