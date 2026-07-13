# C# → Dart porting guide

How to port `Microsoft.Extensions.*` C# source to this Dart workspace. This is
the authoritative porting reference; `rules.md` at the repo root is general
Dart/Flutter style, not porting guidance. For per-subsystem port status and the
list of types intentionally not ported, see [drift-ledger.md](drift-ledger.md).

A broader, generic C#→Dart matrix may also be auto-loaded from user-level
rules (`~/.claude/rules/dart/csharp-to-dart.md` and
`csharp-extensions-to-dart.md`) on the maintainer's machine. Those are
environment-specific; where they and this file disagree about this repo,
this file wins.

## Upstream locations

Two upstream repos, with different layouts. Both verified 2026-07-06.

| Repo | Path template | Notes |
|---|---|---|
| `dotnet/runtime` | `src/libraries/Microsoft.Extensions.<Name>/src/` | lowercase `libraries`, **has** `/src` suffix |
| `dotnet/extensions` | `src/Libraries/Microsoft.Extensions.<Name>/` | capital `Libraries`, **no** `/src` suffix |

Do not "fix" a `dotnet/extensions` URL by appending `/src` — that returns 404.
If a URL 404s, list the parent directory via the GitHub Contents API to
discover the real structure instead of guessing.

- Contents API: `https://api.github.com/repos/<repo>/contents/<path>`
- Raw file: `https://raw.githubusercontent.com/<repo>/main/<path>`

The Dart `diagnostics` subsystem ports **dotnet/runtime**
`Microsoft.Extensions.Diagnostics` (metrics), not the dotnet/extensions
package of the same name. AI Realtime lives inside the dotnet/extensions AI
libraries (port referenced upstream commit `2e537166`).

## Type-mapping matrix

| C# construct | Dart port | Example in this repo |
|---|---|---|
| `interface` with multiple implementations | `abstract interface class` | `lib/src/logging/logger.dart` |
| `interface` with one implementation | single concrete class | — |
| Runtime reflection (`Activator`, `typeof`-driven) | explicit factory / serializer registration supplied by the caller | `DistributedCachingChatClient` takes an explicit serializer pair |
| Method overloads, same semantics | one method with named parameters | throughout |
| Method overloads, different semantics | distinct method names | vector_data: `getAsync` / `getBatchAsync` / `getFilteredAsync` |
| `IAsyncEnumerable<T>` | `Stream<T>` | vector_data, ai streaming |
| LINQ expression trees (`Expression<Func<...>>`) | sealed class hierarchy | `VectorStoreFilter` + `EqualToVectorStoreFilter` etc. |
| Property-selector expressions | `String` field/property names | vector_data options classes |
| `struct` used as mutable frame | class with explicit shallow `copy()` | globbing `PatternContext` frames (stem list intentionally shared) |
| `internal` | library-private `_` or `part` files | globbing `internal/` |
| `IDisposable` | explicit `dispose()` / `close()` + `try/finally` | primitives disposables |
| Fluent builder that only accumulates | plain `List<...>` of value objects | `OrderByDefinition` → `List<OrderByClause>` |
| Closed set of magic strings | value-object class with `const` instances | `ChatRole`; realtime `RealtimeServerMessageType`, `RealtimeSessionKind` |
| `[JsonConverter]` / `[JsonConstructor]` layers | dropped — pass through via `rawRepresentation` | ai realtime data model |
| Generic type parameter used only for reflection | `Type?` field | `VectorStoreVectorProperty<TInput>` → `Type? embeddingType` |

## Naming

- PascalCase type → snake_case file. Treat all-caps acronyms as one token:
  `AIContent` → `ai_content.dart`, `HTTP` → `http`, `DI` → `di`,
  `JSON` → `json`, `URI` → `uri`. Insert `_` before each uppercase letter that
  follows a lowercase letter or the end of an acronym token
  (`ChatClientBuilder` → `chat_client_builder.dart`).
- Drop the C# `I` prefix (`ILogger` → `Logger`) **except** where the bare name
  collides: the globbing internals keep `IPattern` / `IPatternContext` /
  `IPatternSegment` because `Pattern` collides with `dart:core` and
  `PatternContext` with the abstract base class. Document any new exception in
  a dartdoc comment on the type.
- Members renamed to Dart conventions (`IsEmpty` → `isEmpty`) are not drift.

## Conventions and recurring gotchas

- **Delegating clients forward `getService`** to the inner client (see
  `DelegatingChatClient`); do not port upstream's `this is T` check.
- **Skip `*Extensions` classes** whose only content is `getService` /
  `getRequiredService` overloads — those collapse into the interface method
  (e.g. `RealtimeClientExtensions` was skipped).
- **`getService` must be nullable** per contract; return `null` for unknown
  types instead of throwing (`EmptyServiceProvider` bug fixed 2026-06-21).
- **Tests importing `system.dart`** collide with `package:test`'s `equals`
  matcher — use `import 'package:extensions/system.dart' hide equals;`.
- **`package:glob` is banned from `file_system_globbing`** (its semantics
  drifted from .NET, e.g. `**/*.txt` root-level matching); the subsystem uses
  the upstream-faithful engine under
  `lib/src/file_system_globbing/internal/`. `package:glob` remains in use by
  `file_providers` (`polling_wildcard_change_token.dart`,
  `physical_files_watcher.dart`).
- **`lib/src/system/`** holds local Dart utility types (disposables,
  threading, string helpers) with no upstream counterpart — never audit it for
  drift.
- Long-lived streaming loops (realtime function invocation): on hitting an
  iteration limit, `continue` — do not end the stream.
- New types must be exported from the subsystem barrel in
  `packages/extensions/lib/` and covered by tests mirroring `lib/src/` under
  `test/`.

## What not to port

Surface that fundamentally requires runtime reflection or .NET codegen is
recorded as N/A in [drift-ledger.md](drift-ledger.md) — check it **before**
porting and add new N/A decisions there with a one-line reason. Examples:
JSON-schema *creation* from types (needs reflection/codegen; only
transform/validate parts are portable), vector_data `ProviderServices/`,
`BinaryEmbedding` (Dart `Embedding` is non-generic).

## Workflow for closing a gap

1. Run `/drift <subsystem>` to get the current gap list (it applies the
   ledger's N/A filter).
2. Fetch the C# source via the raw URL template above; port following the
   matrix and naming rules here.
3. Wire up: barrel export, dartdoc on public APIs, tests
   (Arrange-Act-Assert, fakes over mocks), 80-char lines.
4. `cd packages/extensions && dart analyze && dart test`.
5. Update [drift-ledger.md](drift-ledger.md): status, date, and any new N/A
   decisions.
