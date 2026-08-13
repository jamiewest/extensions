# Drift ledger

Checked-in state of the C# → Dart port audit. The `/drift` command reads this
file to filter intentional divergences out of its report and updates it after
each run. Porting rules live in [porting.md](porting.md).

## Subsystem status

Upstream paths verified 2026-07-06. "Last audited" is the date of the most
recent `/drift` run covering that subsystem.

| Subsystem | Upstream repo | Upstream path | Dart folder (`packages/extensions/lib/src/`) | Status | Last audited |
|---|---|---|---|---|---|
| hosting | dotnet/runtime | `src/libraries/Microsoft.Extensions.Hosting/src/` | `hosting/` | ported; no gaps | 2026-08-13 |
| dependency_injection | dotnet/runtime | `src/libraries/Microsoft.Extensions.DependencyInjection/src/` | `dependency_injection/` | ported; 4 portable call-site types open (see priorities) | 2026-08-13 |
| logging | dotnet/runtime | `src/libraries/Microsoft.Extensions.Logging/src/` | `logging/` | ported; `LoggerFactory` `options`/`scopeProvider` ctor params open | 2026-08-13 |
| configuration | dotnet/runtime | `src/libraries/Microsoft.Extensions.Configuration/src/` | `configuration/` | ported; ReferenceCountedProviders, `ConfigurationKeyComparer`, `ConfigurationSectionDebugView` open | 2026-08-13 |
| options | dotnet/runtime | `src/libraries/Microsoft.Extensions.Options/src/` | `options/` | ported; async validation + `OptionsMonitorExtensions` open | 2026-08-13 |
| caching | dotnet/runtime | `src/libraries/Microsoft.Extensions.Caching.Memory/src/` | `caching/` | ported; `MemoryCache.Count`/`Keys` + logger/meter ctor hooks open | 2026-08-13 |
| http | dotnet/runtime | `src/libraries/Microsoft.Extensions.Http/src/` | `http/` | ported; DI-layer gap closed 2026-07-13 (tracking entries + timer cleanup, `addAsKeyed`, `configureAdditionalHttpMessageHandlers` ported; remainder collapsed/N/A — see tables) | 2026-08-13 |
| primitives | dotnet/runtime | `src/libraries/Microsoft.Extensions.Primitives/src/` | `primitives/` | ported; StringSegment family (6 types) + async `ChangeToken.onChange` overloads open | 2026-08-13 |
| file_providers | dotnet/runtime | `src/libraries/Microsoft.Extensions.FileProviders.Physical/src/` | `file_providers/` | ported; internal `Clock`/`IClock`/`FileSystemInfoHelper` not mirrored (minor) | 2026-08-13 |
| file_system_globbing | dotnet/runtime | `src/libraries/Microsoft.Extensions.FileSystemGlobbing/src/` | `file_system_globbing/` | fully ported incl. `Internal/` (2026-07-04) | 2026-08-13 |
| diagnostics | dotnet/runtime | `src/libraries/Microsoft.Extensions.Diagnostics/src/` | `diagnostics/` | metrics ported; `Tracing/` ruled N/A 2026-07-13 (would require an Activity mini-port) | 2026-08-13 |
| ai | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Abstractions/` + `src/Libraries/Microsoft.Extensions.AI/` | `ai/` | ported (220/254 upstream files; rest N/A or open); `ChatRouting/` family (6 types, upstream `[Experimental]`), the `UsageDetails`/`AIFunction`/`ChatResponseExtensions` member gaps, and the `Common/` invocation processor+logger all closed 2026-08-04; OTel spans-only | 2026-08-13 |
| ai (realtime) | dotnet/extensions | inside the AI libraries above (ref commit `2e537166`) | `ai/realtime/` | P1–P5 done (P5 OpenTelemetry ported 2026-07-13, spans-only via `dart:developer` Timeline); no new gaps 2026-08-04 | 2026-08-13 |
| vector_data | dotnet/extensions | `src/Libraries/Microsoft.Extensions.VectorData.Abstractions/` | `vector_data/` | ported incl. `provider_services/` core; `ProviderServices/Filter/` trio open | 2026-08-13 |
| ai (evaluation) | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Evaluation{,.NLP,.Quality,.Reporting,.Safety,.Console,.Reporting.Azure}/` | `ai/evaluation/` | **first audited 2026-08-13** — was ported without ever being in audit scope. 82/137 upstream files matched; 55 unmatched, scope decision pending (see priorities) | 2026-08-13 |
| ai (open_ai) | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.OpenAI/` | `ai/open_ai/` | **first audited 2026-08-13** — same story. 6/21 upstream files matched; the Dart side is a hand-rolled minimal client, not a port of the OpenAI .NET SDK adapters. Scope decision pending | 2026-08-13 |

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

## Open priorities

Full-scope audit 2026-08-13. **No new upstream drift**: every unmatched type
in the 13 scoped subsystems was already an N/A entry or a known open item
below. The new findings are scope and hygiene, not missed ports.

1. **Unaudited ported scope (new 2026-08-13, decide first)** — two upstream
   library families are ported in `lib/src/ai/` but had never been in the
   `/drift` scope table, so they had never been audited:
   - `ai/evaluation/` ← `Microsoft.Extensions.AI.Evaluation` + `.NLP` /
     `.Quality` / `.Reporting` / `.Safety` / `.Console` / `.Reporting.Azure`
     — 82/137 upstream files matched, 55 unmatched. The unmatched set splits
     three ways and each needs a recorded decision: (a) likely N/A —
     `*Extensions` helper classes, `JsonSerialization/` converters
     (`CamelCaseEnumConverter`, `TimeSpanConverter`, `SerializerContext`,
     `JsonUtilities`), and utility types (`TimingHelper`, `TaskExtensions`,
     `PathValidation`, `ModelInfo`); (b) probably out of scope as whole
     libraries — `.Console` (12 files, a `System.CommandLine` CLI) and
     `.Reporting.Azure` (6 files, Azure Storage SDK); (c) genuine gaps —
     `ContentSafetyService` + its payload family (8 files, the Azure AI
     Content Safety client backing the `safety/` evaluators),
     `HtmlReportWriter` / `JsonReportWriter` / `IEvaluationReportWriter` /
     `Dataset`, and `IntentResolutionRating`.
   - `ai/open_ai/` ← `Microsoft.Extensions.AI.OpenAI` — 6/21 matched. The
     Dart side is a hand-rolled minimal client; upstream's file set is
     adapters over the official OpenAI .NET SDK (`OpenAIResponsesChatClient`,
     `OpenAIAssistantsChatClient`, `OpenAIRealtimeClient`, the
     `MicrosoftExtensionsAI*Extensions` bridges). There is no OpenAI Dart SDK
     to adapt, so this is likely "Dart-only reimplementation, N/A by
     library" — but it must be written down, not left implicit.

   Scope rows for both were added to `.claude/commands/drift.md` on
   2026-08-13, so the next `all` run covers them; what is still owed is the
   N/A / port rulings, recorded here.

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
   - `IMetricListenerConfigurationFactory`
     (`diagnostics/configuration/`) is an `I`-prefixed name outside the
     documented globbing exception — rename to
     `MetricListenerConfigurationFactory` or record the exception.
   - `diagnostics/debug_console_metric_listener.dart` uses `print()` (3
     sites). Intentional for a debug console listener, but it should either
     move to `dart:developer` `log()` or carry a dartdoc note.

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
     no counterpart in upstream main (re-checked 2026-08-13) — keep.
   - Abstraction-side `*Extensions` helpers: `EmbeddingGeneratorExtensions`,
     `ImageGeneratorExtensions`, `SpeechToTextClientExtensions`,
     `SpeechToTextResponseUpdateExtensions`, `TextToSpeechClientExtensions`,
     `TextToSpeechResponseUpdateExtensions`, `HostedFileClientExtensions`.
   - `AIJsonUtilities`/JSON-schema family (transform/validate parts only,
     ~6 types, design-heavy); `AnonymousDelegatingEmbeddingGenerator`;
     `HostedFileDownloadStream`; `TextToSpeechResponseUpdateKind`.
   - OTel note: decorators for chat/embeddings/image/TTS/STT/files/realtime
     all exist, spans-only via `dart:developer` Timeline (never port
     `Activity`/`ActivitySource`). `OtelMessageParts`, `OtelMessageSerializer`,
     `OpenTelemetryLog`, `TelemetryHelpers` live unexported under
     `lib/src/ai/common/`. Upstream reads
     `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT`; the Dart port
     avoids `dart:io`, so hosts set
     `TelemetryHelpers.enableSensitiveDataDefault` at bootstrap.

5. **Test coverage** — 997 tests pass, but only 63 of 491 substantive source
   files (≥20 non-blank lines) have a same-named `*_test.dart`. The 1:1
   filename heuristic understates real coverage (many tests cover several
   files), so treat this as a hot-spot map rather than a percentage: `ai`
   accounts for 221 of the 428 untested files — `evaluation` (68),
   `chat_completion` (30), `realtime` (29) — followed by `configuration`
   (36) and `logging` (32). Largest untested single files:
   `ai/evaluation/reporting/storage/disk_based_result_store.dart` (353
   lines), `ai/chat_completion/function_invoking_chat_client.dart` (326),
   `ai/chat_routing/semantic_routing_chat_client.dart` (309).

6. **Smaller** (all re-confirmed still open 2026-08-13) —
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
