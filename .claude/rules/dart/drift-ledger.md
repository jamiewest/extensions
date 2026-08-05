# Drift ledger

Checked-in state of the C# → Dart port audit. The `/drift` command reads this
file to filter intentional divergences out of its report and updates it after
each run. Porting rules live in [porting.md](porting.md).

## Subsystem status

Upstream paths verified 2026-07-06. "Last audited" is the date of the most
recent `/drift` run covering that subsystem.

| Subsystem | Upstream repo | Upstream path | Dart folder (`packages/extensions/lib/src/`) | Status | Last audited |
|---|---|---|---|---|---|
| hosting | dotnet/runtime | `src/libraries/Microsoft.Extensions.Hosting/src/` | `hosting/` | ported; no gaps | 2026-07-12 |
| dependency_injection | dotnet/runtime | `src/libraries/Microsoft.Extensions.DependencyInjection/src/` | `dependency_injection/` | ported; 4 portable call-site types open (see priorities) | 2026-07-12 |
| logging | dotnet/runtime | `src/libraries/Microsoft.Extensions.Logging/src/` | `logging/` | ported; `LoggerFactory` `options`/`scopeProvider` ctor params open | 2026-07-12 |
| configuration | dotnet/runtime | `src/libraries/Microsoft.Extensions.Configuration/src/` | `configuration/` | ported; ReferenceCountedProviders, `ConfigurationKeyComparer`, `ConfigurationSectionDebugView` open | 2026-07-12 |
| options | dotnet/runtime | `src/libraries/Microsoft.Extensions.Options/src/` | `options/` | ported; async validation + `OptionsMonitorExtensions` open | 2026-07-12 |
| caching | dotnet/runtime | `src/libraries/Microsoft.Extensions.Caching.Memory/src/` | `caching/` | ported; `MemoryCache.Count`/`Keys` + logger/meter ctor hooks open | 2026-07-12 |
| http | dotnet/runtime | `src/libraries/Microsoft.Extensions.Http/src/` | `http/` | ported; DI-layer gap closed 2026-07-13 (tracking entries + timer cleanup, `addAsKeyed`, `configureAdditionalHttpMessageHandlers` ported; remainder collapsed/N/A — see tables) | 2026-07-13 |
| primitives | dotnet/runtime | `src/libraries/Microsoft.Extensions.Primitives/src/` | `primitives/` | ported; StringSegment family (6 types) + async `ChangeToken.onChange` overloads open | 2026-07-12 |
| file_providers | dotnet/runtime | `src/libraries/Microsoft.Extensions.FileProviders.Physical/src/` | `file_providers/` | ported; internal `Clock`/`IClock`/`FileSystemInfoHelper` not mirrored (minor) | 2026-07-12 |
| file_system_globbing | dotnet/runtime | `src/libraries/Microsoft.Extensions.FileSystemGlobbing/src/` | `file_system_globbing/` | fully ported incl. `Internal/` (2026-07-04) | 2026-07-12 |
| diagnostics | dotnet/runtime | `src/libraries/Microsoft.Extensions.Diagnostics/src/` | `diagnostics/` | metrics ported; `Tracing/` ruled N/A 2026-07-13 (would require an Activity mini-port) | 2026-07-12 |
| ai | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Abstractions/` + `src/Libraries/Microsoft.Extensions.AI/` | `ai/` | ported (220/254 upstream files; rest N/A or open); `ChatRouting/` family (6 types, upstream `[Experimental]`), the `UsageDetails`/`AIFunction`/`ChatResponseExtensions` member gaps, and the `Common/` invocation processor+logger all closed 2026-08-04; OTel spans-only | 2026-08-04 |
| ai (realtime) | dotnet/extensions | inside the AI libraries above (ref commit `2e537166`) | `ai/realtime/` | P1–P5 done (P5 OpenTelemetry ported 2026-07-13, spans-only via `dart:developer` Timeline); no new gaps 2026-08-04 | 2026-08-04 |
| vector_data | dotnet/extensions | `src/Libraries/Microsoft.Extensions.VectorData.Abstractions/` | `vector_data/` | ported incl. `provider_services/` core; `ProviderServices/Filter/` trio open | 2026-07-12 |

`lib/src/system/` is local Dart utility code with no upstream counterpart —
excluded from all audits.

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

## Open priorities

Most impactful first (ai re-audited 2026-08-04; other subsystems last
audited 2026-07-12/13 — see table):

1. **ai** —
   - CLOSED 2026-08-04: `ChatRouting/` family ported to
     `lib/src/ai/chat_routing/` (decision: port now, dartdoc notes the
     upstream `[Experimental]` status; nested `ScoreAggregation` enum
     flattened to `SemanticRoutingScoreAggregation`; attempts carry an
     explicit `stackTrace` since Dart has no `ExceptionDispatchInfo`).
     Member gaps closed the same day: `UsageDetails` audio/text counts,
     `AIFunction.asDeclarationOnly`, and the `addMessages` family — Dart
     names `addMessagesFromResponse`/`FromUpdates`/`FromUpdate`/
     `FromStream` on `List<ChatMessage>` per the FromX overload
     convention.
   - `Common/` function-invocation refactor: `FunctionInvocationLogger`
     and `FunctionInvocationProcessor` ported 2026-08-04 (unexported,
     `lib/src/ai/common/`) and wired into both
     `FunctionInvokingChatClient` and
     `FunctionInvokingRealtimeClientSession`; `execute_tool` spans are
     emitted via `dart:developer` Timeline. (Loop limits were aligned
     earlier, 2026-07-31.) Still unported from that area:
     approval-request replacement, conversation-id history fixups, and
     `FunctionInvocationContext` wiring (tools cannot set
     `terminate`/observe context yet — the context type exists but is
     not flowed).
   - Dart-only note: `ai/tool_reduction/` (`ToolReducingChatClient`) has
     no counterpart in current upstream main — keep, but re-check on the
     next audit whether upstream landed an equivalent.
   - Abstraction-side `*Extensions` helpers: `EmbeddingGeneratorExtensions`,
     `ImageGeneratorExtensions`, `SpeechToTextClientExtensions`,
     `SpeechToTextResponseUpdateExtensions`, `TextToSpeechClientExtensions`,
     `TextToSpeechResponseUpdateExtensions`, `HostedFileClientExtensions`.
   - `AIJsonUtilities`/JSON-schema family (transform/validate parts only,
     ~6 types, design-heavy); `AnonymousDelegatingEmbeddingGenerator`;
     `HostedFileDownloadStream`; `TextToSpeechResponseUpdateKind`.
   - OTel note: decorators for chat/embeddings/image/TTS/STT/files/
     realtime all exist, spans-only via `dart:developer` Timeline
     (never port `Activity`/`ActivitySource`). `OtelMessageParts`,
     `OtelMessageSerializer`, `OpenTelemetryLog`, `TelemetryHelpers`
     live unexported under `lib/src/ai/common/`. Upstream reads
     `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT`; the Dart
     port avoids `dart:io`, so hosts set
     `TelemetryHelpers.enableSensitiveDataDefault` at bootstrap.
2. **Smaller** —
   - options: async validation (`AsyncValidateOptions`,
     `IAsyncValidateOptions`, `IAsyncStartupValidator`) and
     `OptionsMonitorExtensions` (`onChange` helper).
   - configuration: `ReferenceCountedProviders`(+`Manager`),
     `ConfigurationKeyComparer`, `ConfigurationSectionDebugView`
     (`getDebugView`).
   - primitives: `StringSegment` family (`StringSegment`,
     `StringSegmentComparer`, `StringTokenizer`, `StringValues`,
     `InplaceStringBuilder`, `Extensions`); async
     `ChangeToken.onChange` overloads (defer re-registration until the
     consumer's `Future` completes).
   - dependency_injection: portable call-site types (`ConstructorCallSite`,
     `IEnumerableCallSite`, `CallSiteJsonFormatter`,
     `ServiceLookupHelpers`).
   - caching: `MemoryCache.Count`/`Keys` and `loggerFactory`/`meterFactory`
     ctor hooks (statistics publishing).
   - logging: `LoggerFactory` `options` (`LoggerFactoryOptions`,
     activity tracking) and `scopeProvider` ctor params — scope-provider
     wiring is currently commented out.
   - vector_data: `ProviderServices/Filter/` trio
     (`FilterPreprocessingOptions`, `FilterTranslatorBase`,
     `QueryParameterExpression` — redesign around `VectorStoreFilter`, the
     LINQ-expression inputs don't map directly); reconcile
     `VectorStoreCollection.upsertAsync` return types with current upstream
     (C# returns `Task` with keys populated on records; Dart returns
     `Future<TKey>` / `Stream<TKey>`).
