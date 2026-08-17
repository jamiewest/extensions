# Drift ledger

Checked-in state of the C# → Dart port audit. The `/drift` command reads this
file to filter intentional divergences out of its report and updates it after
each run. Porting rules live in [porting.md](porting.md).

## Subsystem status

Upstream paths verified 2026-07-06 (Contents API) and 2026-08-16 (git trees
API, all 22 library folders, none truncated). "Last audited" is the date of
the most recent `/drift` run covering that subsystem.

| Subsystem | Upstream repo | Upstream path | Dart folder (`packages/extensions/lib/src/`) | Status | Last audited |
|---|---|---|---|---|---|
| hosting | dotnet/runtime | `src/libraries/Microsoft.Extensions.Hosting/src/` | `hosting/` | ported; no gaps | 2026-08-16 |
| dependency_injection | dotnet/runtime | `src/libraries/Microsoft.Extensions.DependencyInjection/src/` | `dependency_injection/` | ported; 4 portable call-site types open (see priorities) | 2026-08-16 |
| logging | dotnet/runtime | `src/libraries/Microsoft.Extensions.Logging/src/` | `logging/` | ported; `LoggerFactory` `options`/`scopeProvider` ctor params open | 2026-08-16 |
| configuration | dotnet/runtime | `src/libraries/Microsoft.Extensions.Configuration/src/` | `configuration/` | ported; ReferenceCountedProviders, `ConfigurationKeyComparer`, `ConfigurationSectionDebugView` open | 2026-08-16 |
| options | dotnet/runtime | `src/libraries/Microsoft.Extensions.Options/src/` | `options/` | ported; async validation + `OptionsMonitorExtensions` open | 2026-08-16 |
| caching | dotnet/runtime | `src/libraries/Microsoft.Extensions.Caching.Memory/src/` | `caching/` | ported; `MemoryCache.Count`/`Keys` + logger/meter ctor hooks open | 2026-08-16 |
| http | dotnet/runtime | `src/libraries/Microsoft.Extensions.Http/src/` | `http/` | ported; DI-layer gap closed 2026-07-13 (tracking entries + timer cleanup, `addAsKeyed`, `configureAdditionalHttpMessageHandlers` ported; remainder collapsed/N/A — see tables) | 2026-08-16 |
| primitives | dotnet/runtime | `src/libraries/Microsoft.Extensions.Primitives/src/` | `primitives/` | ported; StringSegment family (6 types) + async `ChangeToken.onChange` overloads open | 2026-08-16 |
| file_providers | dotnet/runtime | `src/libraries/Microsoft.Extensions.FileProviders.Physical/src/` | `file_providers/` | ported; internal `Clock`/`IClock`/`FileSystemInfoHelper` not mirrored (minor) | 2026-08-16 |
| file_system_globbing | dotnet/runtime | `src/libraries/Microsoft.Extensions.FileSystemGlobbing/src/` | `file_system_globbing/` | fully ported incl. `Internal/` (2026-07-04) | 2026-08-16 |
| diagnostics | dotnet/runtime | `src/libraries/Microsoft.Extensions.Diagnostics/src/` | `diagnostics/` | metrics ported; `Tracing/` ruled N/A 2026-07-13 (would require an Activity mini-port) | 2026-08-16 |
| ai | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Abstractions/` + `src/Libraries/Microsoft.Extensions.AI/` | `ai/` | ported (220/254 upstream files; rest N/A or open); `ChatRouting/` family (6 types, upstream `[Experimental]`), the `UsageDetails`/`AIFunction`/`ChatResponseExtensions` member gaps, and the `Common/` invocation processor+logger all closed 2026-08-04; OTel spans-only | 2026-08-16 |
| ai (realtime) | dotnet/extensions | inside the AI libraries above (ref commit `2e537166`) | `ai/realtime/` | P1–P5 done (P5 OpenTelemetry ported 2026-07-13, spans-only via `dart:developer` Timeline); no new gaps 2026-08-04 | 2026-08-16 |
| vector_data | dotnet/extensions | `src/Libraries/Microsoft.Extensions.VectorData.Abstractions/` | `vector_data/` | ported incl. `provider_services/` core; `ProviderServices/Filter/` trio open | 2026-08-16 |
| ai (evaluation) | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Evaluation{,.NLP,.Quality,.Reporting,.Safety,.Console,.Reporting.Azure}/` | `ai/evaluation/` | **scoped 2026-08-16** — every previously-unmatched type ruled: `.Console` + `.Reporting.Azure` N/A by library, ~20 types N/A by collapse (see table), 4 genuine gap clusters open (report pipeline, IntentResolutionRating protocol, result-level helpers, disk-store hardening — see priorities) | 2026-08-16 |
| ai (open_ai) | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.OpenAI/` | `ai/open_ai/` | **scoped 2026-08-16** — ruled N/A by library: upstream is adapters over the official OpenAI .NET SDK, and no allowlisted OpenAI Dart SDK exists to adapt. The Dart `open_ai/` is a deliberate hand-rolled minimal client. Revisit only if an allowlisted OpenAI Dart SDK appears | 2026-08-16 |

`lib/src/system/` is local Dart utility code with no upstream counterpart —
excluded from all audits.

Not upstream-type files — never report these as missing types, in any
subsystem: `Properties/InternalsVisibleTo.cs`, `Properties/TypeForwards.cs`,
`*.Forwards.cs`, `AssemblyInfo.cs`, `GlobalUsings.cs`, and TFM-conditional
partials (`*.netcoreapp.cs`, `*.notnetcoreapp.cs`). They are build metadata or
compile-time partials of a type that is ported under its own name.

## Intentionally not ported (N/A list)

`/drift` must not report these as missing. Add new entries with a one-line
reason whenever a port decision rules something out.

| Type / area | Subsystem | Reason |
|---|---|---|
| `BinaryEmbedding` | ai | Dart `Embedding` is non-generic (`List<double> vector`); a BitArray-vector subtype doesn't fit |
| `DataUriParser` | ai | collapsed into `dart:core` `UriData`, wired into `DataContent.fromUri` |
| AIJsonUtilities schema *creation* | ai | schema-from-type requires reflection/codegen; only transform/validate parts are portable (still open, see priorities) |
| C# `JsonConverter` / `[JsonConstructor]` layers | ai | no `AIJsonUtilities` port; passthrough via `rawRepresentation` |
| `RealtimeClientExtensions`, `RealtimeClientSessionExtensions` | ai/realtime | only `getService`/`getRequiredService` overloads; collapse into the interface method |
| `IRecordCreator` | vector_data | reflection-based record instantiation; Dart `CollectionModel` takes an explicit `recordFactory` instead |
| `CollectionJsonModelBuilder` | vector_data | System.Text.Json-specific model builder; no STJ counterpart in the Dart port |
| `EmbeddingGenerationDispatcher{TEmbedding}`, `VectorPropertyModel{TInput}` | vector_data | generic reflection variants merged into the non-generic Dart types |
| `IPattern`-family `I` prefixes | file_system_globbing | intentional: `Pattern` collides with `dart:core`, `PatternContext` with the base class — not a conformance violation |
| `IVectorSearchable`, `IKeywordHybridSearchable` typedefs | vector_data | deprecated aliases only — renamed to `VectorSearchable` / `KeywordHybridSearchable` on 2026-07-06 per the no-`I`-prefix rule |
| `ILEmit*` (3), `Expression*` engines (2), `CompiledServiceProviderEngine`, `DynamicServiceProviderEngine`, `StackGuard`, `DependencyInjectionEventSource` | dependency_injection | IL-emit / expression-tree / ETW / runtime-stack machinery — no Dart counterpart; the Dart provider uses the runtime (interpreted) engine only |
| `OptionsValidatorAttribute`, `ValidateEnumeratedItemsAttribute`, `ValidateObjectMembersAttribute`, `NamedValidateOptionsFilter` | options | drive the C# options *source generator*; no codegen in the Dart port — validation is explicit `ValidateOptions` registration |
| `AIFunctionNameAttribute`, `AIParameterNameAttribute` | ai | reflection-read attributes for `AIFunctionFactory`; Dart function tools take explicit names |
| `IChatReducer_Forwarder` | ai | assembly type-forwarder file, not a type |
| `ChatResponse{T}` (structured output) | ai | requires schema-from-type (reflection/codegen) — same rationale as AIJsonUtilities schema creation; revisit if a transform-only design lands |
| `StringComparisonHelper` | file_system_globbing | collapsed into `util/string_comparison.dart` |
| `VectorStoreVectorProperty{TInput}` | vector_data | generic variant merged into non-generic `VectorStoreVectorProperty` via `Type? embeddingType` (see porting.md matrix) |
| `Tracing/` subfolder (7 types) | diagnostics | thin wrappers over `ActivitySource`/`ActivityListener` — porting requires a `System.Diagnostics.Activity` mini-port (6–10 types of framework debt); no in-repo consumer, and AI telemetry uses `dart:developer` Timeline instead. Ruled out 2026-07-13; revisit only if a concrete consumer appears |
| `ISocketsHttpHandlerBuilder`, `DefaultSocketsHttpHandlerBuilder`, `SocketsHttpHandlerBuilderExtensions` | http | configure the dart:io-shaped `SocketsHttpHandler`; `package:http` abstracts transport behind `Client`, and porting these would break web/VM parity. Ruled out 2026-07-13 |
| `OtelContext` | ai | STJ source-generated `JsonSerializerContext` — same rationale as the JsonConverter-layer N/A; plain `dart:convert` maps instead |
| `FunctionInvocationHelpers` | ai | `Activity.Current` inspection (never port `Activity`); the elapsed-time helper collapses to `dart:core` `Stopwatch` at call sites. The sibling `FunctionInvocationLogger`/`FunctionInvocationProcessor` ARE ported (unexported, `lib/src/ai/common/`) |
| `OtelMetricHelpers` | ai | metrics deferred by decision 2026-07-13: OTel decorators are spans-only (`dart:developer` Timeline); revisit if histogram wiring to the diagnostics metrics mini-port is wanted |
| `ITypedHttpClientFactory`, `DefaultTypedHttpClientFactory` | http | collapsed into `HttpClientBuilder.addTypedClient` / `addHttpClientTyped` explicit factories (upstream exists to serve `ActivatorUtilities` reflection) |
| `HttpClientFactoryExtensions`, `HttpMessageHandlerFactoryExtensions` | http | C# default-name overloads — collapsed into optional `name` parameters on `createClient`/`createHandler` |
| `DefaultHttpClientBuilder`, `DefaultHttpClientBuilderServiceCollection`, `DefaultHttpClientConfigurationTracker` | http | builder-caching / config-after-build guard plumbing — collapsed into the concrete `HttpClientBuilder` holding its `ServiceCollection` directly |
| `HttpClientMappingRegistry` | http | validates reflection-based typed-client→name mappings; Dart explicit factories make the registry unnecessary |
| `HttpClientKeyedLifetime` | http | collapsed into `HttpClientBuilder.addAsKeyed`/`removeAsKeyed` (ported 2026-07-13) using keyed `ServiceDescriptor`s |
| `LogHelper`, `HttpHeadersLogValue` | http | collapsed into the existing `logging/` handlers with `shouldRedactHeaderValue` redaction |
| `ValueStopwatch` | http | .NET allocation-avoidance struct; `dart:core` `Stopwatch` at call sites |
| `MetricsFactoryHttpMessageHandlerFilter` | http | wires `IMeterFactory` into `System.Net.Http` telemetry — transport-internal metrics with no `package:http` counterpart |
| `HttpClientBuilderExtensions`, `HttpClientBuilderExtensions.Logging` | http | C# static extension classes over `IHttpClientBuilder`; collapsed into instance methods on the Dart `HttpClientBuilder` (`configureHttpClient`, `addHttpMessageHandler`, `redactLoggedHeaders`, `setHandlerLifetime`, `addAsKeyed`, …). Verified member-for-member 2026-08-13 |
| `NamedAsyncValidateOptionsFilter` | options | async sibling of `NamedValidateOptionsFilter`; both drive the C# options source generator, and there is no codegen in the Dart port |
| `CacheEntry.CacheEntryTokens` | caching | C# partial splitting `CacheEntry`'s token bookkeeping; the Dart `CacheEntry`/`MemoryCacheEntryOptions` carry `expirationTokens` + `postEvictionCallbacks` directly |
| `Microsoft.Extensions.AI.Evaluation.Console` (whole library: `Program`, `Commands/`, its `Telemetry/` + `Utilities/` helpers) | ai (evaluation) | executable dotnet CLI tool, not library surface; a Dart equivalent would be a new `bin/` tool designed for pub, out of port scope. Ruled 2026-08-16 |
| `Microsoft.Extensions.AI.Evaluation.Reporting.Azure` (whole library: `AzureStorage*` types) | ai (evaluation) | Azure Blob Storage bindings over the Azure.Storage .NET SDK; no allowlisted Azure Storage Dart package. Disk-based stores are ported. Ruled 2026-08-16 |
| OpenAI .NET SDK adapter layer (all 15 unmatched `Microsoft.Extensions.AI.OpenAI` types: `OpenAIResponsesChatClient`, `OpenAIAssistantsChatClient`, `OpenAIRealtimeClient`, `OpenAIRealtimeClientSession`, `OpenAIRealtimeConversationClient`, `OpenAIHostedFileClient`, `OpenAIFileDownloadStream`, `MicrosoftExtensionsAIAssistantsExtensions`, `MicrosoftExtensionsAIChatExtensions`, `MicrosoftExtensionsAIRealtimeExtensions`, `MicrosoftExtensionsAIResponsesExtensions`, `OpenAIJsonContext`, `OpenAIRequestPolicies`, `RequestOptionsExtensions`, `ResponsesClientContinuationToken` — names spelled out so the audit's literal matcher filters them) | ai (open_ai) | adapters over the official OpenAI .NET SDK; no allowlisted OpenAI Dart SDK to adapt — the Dart `open_ai/` is a hand-rolled minimal REST client instead. Ruled 2026-08-16 |
| `ChatMessageExtensions` (Evaluation core + internal Quality/Safety copies) | ai (evaluation) | collapsed into `QualityMessageListExtensions` (`quality/quality_evaluator_base.dart`) and `ChatMessageListExtensions` |
| `EvaluatorExtensions` | ai (evaluation) | C# `EvaluateAsync` convenience overloads collapse into the single `Evaluator.evaluate(messages, modelResponse, …)`; callers pass `const []` |
| `ScenarioRunExtensions` | ai (evaluation) | `EvaluateAsync` overloads collapse into the `ScenarioRun.evaluate` instance method |
| `ChatDetailsExtensions` | ai (evaluation) | collapsed into the `ChatDetails.addTurnDetails` instance method |
| `NGramExtensions` | ai (evaluation) | collapsed into `NGramListExtensions` (`createNGrams`/`createNGramCounts`) in `nlp/common/n_gram.dart` |
| `AIToolExtensions` | ai (evaluation) | internal `RenderAsJson`; tool rendering is inlined in `ToolCallAccuracyEvaluatorContext` and the quality evaluators |
| `JsonOutputFixer` | ai (evaluation) | markdown-fence stripping inlined in `relevance_truth_and_completeness_rating.dart` parsing |
| `SerializerContext` (Quality), `CamelCaseEnumConverter`, `EvaluationContextConverter`, `TimeSpanConverter`, `JsonUtilities` (Reporting) | ai (evaluation) | STJ source-gen/converter layer; plain `dart:convert` maps instead — same rationale as `OtelContext` |
| `SimpleChatClient` | ai (evaluation) | turn-detail recording collapsed into `ResponseCachingChatClient` (constructs `ChatTurnDetails` directly) |
| `Defaults` | ai (evaluation) | three constants inlined at use sites (`'Default'` execution name in `reporting_configuration.dart`, 14-day TTL in `disk_based_response_cache.dart`) |
| `TimingHelper`, `TaskExtensions` | ai (evaluation) | `Stopwatch` / `Future.wait` at call sites — same rationale as `ValueStopwatch` |
| `ContentSafetyChatClient`, `ContentSafetyChatOptions`, `ContentSafetyServiceConfigurationExtensions` | ai (evaluation) | the IChatClient facade over the safety service; unneeded — Dart safety evaluators call the service directly via the `ContentSafetyEvaluator` base class |
| `ContentSafetyService` + payload family (`ContentSafetyServicePayloadFormat`, `ContentSafetyServicePayloadStrategy`, `ContentSafetyServicePayloadUtilities`) | ai (evaluation) | collapsed into the `ContentSafetyEvaluator` base + `ContentSafetyServiceConfiguration` (simplified single-payload client). Fidelity caveat: upstream's 565-line payload builder handles per-task/multimodal formats and LRO polling the Dart client does not — revisit if a safety task mis-serves (tracked in priorities) |
| `TextToSpeechClientExtensions` | ai | only `getService` overloads; collapses into the interface method (same rule as `RealtimeClientExtensions`). Ruled 2026-08-16 |
| `HostedFileDownloadStream` | ai | collapsed: `HostedFileClient.download` returns a plain `Stream<List<int>>` and the file's media type/name come from `getFile` (see `HostedFileClientExtensions.downloadAsDataContent`); `DownloadToAsync` is `dart:io`-bound and the AI abstractions stay io-free — callers pipe the stream. Ruled 2026-08-16 |
| `AIJsonSchemaCreateContext`, `AIJsonSchemaCreateOptions` | ai | belong to the schema-*creation* side (`AIJsonUtilities.Schema.Create.cs`), which is N/A per the existing schema-creation row. Ruled 2026-08-16 |

## Open priorities

Full-scope audit 2026-08-16, confirmed by a second same-day run after the
scope rulings, the ai port batch, and the I-prefix cleanup landed. The
confirmation run verified upstream file sets are *identical* (not just
equal counts) to the morning fetch, and that the open set now reduces to
exactly the items below: ai is down to the 3 AIJsonSchemaTransform types,
evaluation to the 4 recorded gap clusters (11 types + 3 payload watch
items), and diagnostics/http/globbing to zero. **No new upstream drift**:
upstream counts are unchanged since 2026-08-13 (AI 254, evaluation
137, OpenAI 21) and every unmatched type across all 15 scope rows was
already an N/A entry or a known open item below. API surface sample
(10 types: IChatClient, IEmbeddingGenerator, ILoggerFactory,
IOptionsMonitor, IMemoryCache, IConfigurationBuilder, IHost,
ServiceDescriptor, IChangeToken, PhysicalFileProvider): no member gaps —
C# `ServiceDescriptor.Describe`/`DescribeKeyed` collapse into the Dart
public constructor's `lifetime` + factory parameters. The audit ran at
language version 3.13 (constraints raised 2026-08-16); either constructor
form remains a correct port of a C# primary constructor.

1. **Evaluation genuine gaps (scoped 2026-08-16; rulings recorded)** — the
   2026-08-13 "scope decision pending" item is resolved: `.Console`,
   `.Reporting.Azure`, and the OpenAI adapter layer are N/A by library, and
   ~20 helper/serialization types are N/A by collapse (all in the N/A table
   with evidence). Every characterization was verified against fetched
   upstream source, not assumed. What remains are four genuine gap
   clusters, in priority order:
   - **Report generation pipeline** (`IEvaluationReportWriter`,
     `JsonReportWriter` + `Dataset`, `HtmlReportWriter`): the Dart reporting
     layer stores results (`disk_based_result_store.dart`) but cannot render
     a report. `JsonReportWriter`+`Dataset` are small and mechanical;
     `HtmlReportWriter` embeds a template built from upstream's
     `TypeScript/` frontend, so it needs a template-sourcing decision first.
     Fold in `BuiltInMetricUtilities` (metric-metadata stamping the report
     UI reads — Dart evaluators do not stamp `eval-model`/token metadata)
     and `ModelInfo` (well-known model tables) as the writers need them.
   - **`IntentResolutionRating` + evaluator protocol**: upstream's
     `IntentResolutionEvaluator` asks the judge model for a JSON payload
     parsed into a typed rating (`resolution_score`,
     `agent_perceived_intent`, …); the Dart evaluator still uses the older
     `<S0>/<S1>/<S2>` tag protocol with a bare 1–5 score. Port the rating
     type following the in-repo `relevance_truth_and_completeness_rating.dart`
     pattern and rework the prompt/parse to match upstream.
   - **Result-level helpers**: `EvaluationResultExtensions`'s bulk mutators
     (`AddOrUpdate*InAllMetrics`, `AddDiagnosticsToAllMetrics`,
     result-level `Interpret`/`ContainsDiagnostics`) and
     `ScenarioRunResultExtensions.ContainsDiagnostics` — the metric-level
     halves exist in `evaluation_metric_extensions.dart`; the result-level
     loops do not. Small.
   - **Disk-store hardening** (minor): `PathValidation`
     (`EnsureWithinRoot` path-traversal guard — scenario names become
     directory segments unguarded in the Dart disk stores) and
     `IterationNameComparer` (natural ordering of iteration names).
   - Safety payload fidelity (watch item, no action): see the
     `ContentSafetyService` N/A row's caveat.

2. **Doc examples: 25 hand-written barrel snippets still unverified (new
   2026-08-13)** — the example set was reorganised the same day: 18 runnable
   files under `packages/extensions/example/` plus the `extensions_flutter`
   example, 40 `{@example}` references into 38 marked regions, indexed by
   `packages/extensions/example/README.md`. Every referenced block is
   compiled by `dart analyze` and executed by `dart run`
   (`flutter test` for the Flutter one). `example/example.dart` stays put:
   pub.dev's Example-tab lookup order puts `example/example.dart` ahead of
   `example/README.md`, so adding the index did not displace the tab.
   What remains are the *unconverted* inline ```dart blocks in the barrels
   (25 across 14 files), and they are demonstrably drifting — three that were
   converted on 2026-08-13 documented APIs that do not exist (`hosting.dart`
   called `BackgroundService.executeAsync`; the Dart method is `execute`).
   Still uncorrected as of that date, verified against the current
   signatures:
   - `dependency_injection.dart` § "Keyed Services":
     `addKeyedSingleton<ICache, RedisCache>('redis')` — the real signature is
     `addKeyedSingleton<TService>(Object? serviceKey,
     KeyedImplementationFactory implementationFactory)`, one type argument
     plus a factory.
   - `options.dart` § "Basic Usage": `configure<MyOptions>((options) {…})` —
     the real signature is `configure<TOptions>(OptionsImplementationFactory
     instance, ConfigureOptionsAction configureOptions, {String? name})`, so
     the snippet is missing the factory argument.
   - `logging.dart` § "Scoped Logging" uses a bare `using(...)` helper; check
     it resolves before converting.

   Convert each to a region reference as its subsystem gets an example, and
   treat a barrel snippet that cannot be backed by compiling code as a bug
   report about the docs.

3. **Toolchain hygiene (new 2026-08-13)** —
   - ~~`analysis_options.yaml` 80-char rule silently ignored~~ — **closed
     2026-08-13.** The rule was written as
     `- lines_longer_than_80_chars: true`, a list entry holding a map, which
     the analyzer ignores. Corrected to a bare entry in `extensions` (17
     violations, not the 12 estimated) and added to `extensions_flutter`,
     which had no such rule at all (5 more). All 22 were comments, doc text,
     or string literals the formatter cannot break; three needed small
     restructures. Both packages analyze clean.
   - ~~`IMetricListenerConfigurationFactory`~~ — **closed 2026-08-16.**
     The earlier rename suggestion assumed no concrete existed; in fact
     `MetricListenerConfigurationFactory` already implemented it as the
     only implementation, so the interface collapsed into the concrete per
     the porting matrix and its file was deleted.
   - `diagnostics/debug_console_metric_listener.dart` uses `print()` (3
     sites). Intentional for a debug console listener, but it should either
     move to `dart:developer` `log()` or carry a dartdoc note.
   - ~~`IConfiguration`/`IConfigurationSection` I-prefix inversion~~ —
     **closed 2026-08-16**, riding the 0.8.0 break: `Configuration` is now
     the abstract type and `IConfiguration` a `@Deprecated` typedef (remove
     in the release after 0.8.0). `IConfigurationSection` keeps its `I` as
     a documented exception — the bare name is taken by the concrete
     `ConfigurationSection`, the same collision rule as the globbing
     `IPattern` family (dartdoc on the type records this). Found by a
     broader grep (`^abstract class I[A-Z]`) than the audit's
     `^abstract interface class I[A-Z]` pattern, which is why three prior
     full audits missed it.
   - Cosmetic remainder (filename-only): `logging/` keeps
     `i_logger_provider_configuration.dart` and
     `i_logger_provider_configuration_factory.dart` as filenames although
     the types inside were long since renamed without the prefix; the
     natural factory filename is taken by the `*Impl` file. Their stale
     `[ILoggerProviderConfiguration*]` dartdoc references were fixed
     2026-08-16 (4 of the 19 standing dartdoc warnings).
   - ~~`.claude/commands/drift.md` primary-constructor note stale~~ —
     **fixed 2026-08-16**: it still described the workspace as pinned to
     `^3.6.0`/`^3.10.1` after the 3.13 bump; now defers to porting.md as
     authoritative.

4. **ai** — unchanged from the 2026-08-04 audit; upstream `AI` +
   `AI.Abstractions` are still at 254 files with no new types.
   - `Common/` function-invocation refactor: `FunctionInvocationLogger` and
     `FunctionInvocationProcessor` ported 2026-08-04 (unexported,
     `lib/src/ai/common/`) and wired into both `FunctionInvokingChatClient`
     and `FunctionInvokingRealtimeClientSession`; `execute_tool` spans are
     emitted via `dart:developer` Timeline. Still unported from that area:
     approval-request replacement, conversation-id history fixups, and
     `FunctionInvocationContext` wiring (tools cannot set `terminate`/observe
     context yet — the context type exists but is not flowed).
   - Dart-only note: `ai/tool_reduction/` (`ToolReducingChatClient`) still has
     no counterpart in upstream main (re-checked 2026-08-16) — keep.
   - ~~Abstraction-side `*Extensions` helpers~~ — **closed 2026-08-16.**
     Six ported as Dart extensions with tests (`EmbeddingGenerator`,
     `ImageGenerator`, `SpeechToTextClient`, `SpeechToTextResponseUpdate`,
     `TextToSpeechResponseUpdate`, `HostedFileClient`);
     `TextToSpeechClientExtensions` ruled N/A (getService-only). Also ported
     the same day: `TextToSpeechResponseUpdateKind` (+ a `kind` field on the
     update, defaulting to `audioUpdating` per upstream) and
     `AnonymousDelegatingEmbeddingGenerator` (public, wired via
     `EmbeddingGeneratorBuilder.useGenerate`).
     `HostedFileDownloadStream` ruled N/A (see table).
   - **STT streaming interface fixed 2026-08-16** (breaking, rides 0.8.0):
     `SpeechToTextClient.getStreamingText` returned
     `Stream<SpeechToTextResponse>` while upstream streams *updates*, and
     the already-ported `SpeechToTextResponseUpdate` type was dead code.
     Now returns `Stream<SpeechToTextResponseUpdate>` across the interface,
     all four decorators, and the OpenAI client.
   - Small new gap (found 2026-08-16): hosted-file scope plumbing —
     upstream `HostedFileClientOptions.Scope` and `HostedFileContent.Scope`
     have no Dart counterpart, so the `downloadFromContent` convenience
     cannot propagate scope.
   - `AIJsonUtilities`/JSON-schema family, re-scoped 2026-08-16: what
     remains portable is `AIJsonSchemaTransformCache` /
     `AIJsonSchemaTransformContext` / `AIJsonSchemaTransformOptions` plus
     the transform walker in `AIJsonUtilities.Schema.Transform.cs` (~9 KB
     over `Map<String, Object?>` schemas) and the shared helpers it uses
     from `AIJsonUtilities.cs`. Schema *creation*
     (`AIJsonUtilities.Schema.Create.cs`, 42 KB, reflection-driven) stays
     N/A, and `AIJsonSchemaCreateContext`/`CreateOptions` go with it.
     Design-heavy; the one remaining open ai port.
   - OTel note: decorators for chat/embeddings/image/TTS/STT/files/realtime
     all exist, spans-only via `dart:developer` Timeline (never port
     `Activity`/`ActivitySource`). `OtelMessageParts`, `OtelMessageSerializer`,
     `OpenTelemetryLog`, `TelemetryHelpers` live unexported under
     `lib/src/ai/common/`. Upstream reads
     `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT`; the Dart port
     avoids `dart:io`, so hosts set
     `TelemetryHelpers.enableSensitiveDataDefault` at bootstrap.

5. **Test coverage** — 997 tests pass, but only 63 of 489 substantive source
   files (≥20 non-blank lines; recounted 2026-08-16 after the tall-style
   reformat) have a same-named `*_test.dart`. The 1:1
   filename heuristic understates real coverage (many tests cover several
   files), so treat this as a hot-spot map rather than a percentage: `ai`
   accounts for 221 of the 428 untested files — `evaluation` (68),
   `chat_completion` (30), `realtime` (29) — followed by `configuration`
   (36) and `logging` (32). Largest untested single files:
   `ai/evaluation/reporting/storage/disk_based_result_store.dart` (353
   lines), `ai/chat_completion/function_invoking_chat_client.dart` (326),
   `ai/chat_routing/semantic_routing_chat_client.dart` (309).

6. **Smaller** (all re-confirmed still open 2026-08-16) —
   - options: async validation (`AsyncValidateOptions`,
     `IAsyncValidateOptions`, `IAsyncStartupValidator`) and
     `OptionsMonitorExtensions` (`onChange` helper).
   - configuration: `ReferenceCountedProviders`(+`Manager`),
     `ConfigurationKeyComparer`, `ConfigurationSectionDebugView`
     (`getDebugView`).
   - primitives: `StringSegment` family (`StringSegment`,
     `StringSegmentComparer`, `StringTokenizer`, `StringValues`,
     `InplaceStringBuilder`, `Extensions`); async `ChangeToken.onChange`
     overloads (defer re-registration until the consumer's `Future`
     completes).
   - dependency_injection: portable call-site types (`ConstructorCallSite`,
     `IEnumerableCallSite`, `CallSiteJsonFormatter`, `ServiceLookupHelpers`).
   - caching: `MemoryCache.Count`/`Keys` and `loggerFactory`/`meterFactory`
     ctor hooks (statistics publishing).
   - logging: `LoggerFactory` `options` (`LoggerFactoryOptions`, activity
     tracking) and `scopeProvider` ctor params — scope-provider wiring is
     currently commented out. Confirmed against the C# 6-overload ctor chain.
   - vector_data: `ProviderServices/Filter/` trio (`FilterPreprocessingOptions`,
     `FilterTranslatorBase`, `QueryParameterExpression` — redesign around
     `VectorStoreFilter`, the LINQ-expression inputs don't map directly);
     reconcile `VectorStoreCollection.upsertAsync` return types with current
     upstream (C# returns `Task`/`Task` with keys populated on the records;
     Dart returns `Future<TKey>` / `Stream<TKey>` — confirmed still divergent
     2026-08-13).
   - file_providers: `PollingWildCardChangeToken` **is** ported as
     `polling_wildcard_change_token.dart` (upstream spells it `WildCard`,
     Dart spells it `wildcard`) — a naming variance, not a gap. Internal
     `Clock`/`IClock`/`FileSystemInfoHelper` remain unmirrored (minor).
