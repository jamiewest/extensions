---
description: Check for drift between upstream C# Microsoft.Extensions.* and this Dart port. Use when asked to check drift, port sync, upstream changes, or implementation gaps.
argument-hint: [sync | full | hosting|dependency_injection|logging|configuration|options|caching|http|primitives|file_providers|file_system_globbing|ai|diagnostics|vector_data|runtime|extensions-repo|all] (default: incremental review since last sync)
allowed-tools: [Read, Bash, WebFetch, Glob, Grep, Edit, Write]
---

# Port Drift Check

You are auditing drift between the upstream C# `Microsoft.Extensions.*` source
and this Dart port. The Dart workspace root is the current directory. All
`find`/`grep` paths must be workspace-root-relative.

Two companion files under `.claude/rules/dart/` are part of this workflow:

- `porting.md` — the C# → Dart porting rules (consult it when reporting how a
  gap should be closed).
- `drift-ledger.md` — checked-in audit state: the **upstream sync pins**
  (`upstream-sync(<repo>): <sha> <ISO date>` lines), per-subsystem status, the
  list of types intentionally not ported, and open priorities. You MUST read
  it before anything else, and update it at the end of every run.

## Modes

| Invocation | What it does |
|---|---|
| `/drift` | **Incremental review** — list and classify upstream commits since the sync pins, across both upstream repos. Report only; no code changes. |
| `/drift sync` | Incremental review, then **port the applicable changes**, advance the pins, and prepare a branch + PR. |
| `/drift full` or `/drift all` | Exhaustive structural audit (every subsystem) — the pre-incremental behavior (Step 1 onward). |
| `/drift <subsystem>` / `runtime` / `extensions-repo` | Exhaustive audit scoped per the table below. |

## Namespace scope

If `$ARGUMENTS` is empty or `all`, check every row.
If `$ARGUMENTS` is `runtime`, check only rows whose **Upstream repo** is `dotnet/runtime`.
If `$ARGUMENTS` is `extensions-repo`, check only rows whose **Upstream repo** is `dotnet/extensions`.
Otherwise check only the single named subsystem.

| Argument               | Upstream repo     | C# source path (from repo root)                                                                                      | Dart folder                                            |
|------------------------|-------------------|----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| `hosting`              | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Hosting/src/`                                                                   | `packages/extensions/lib/src/hosting/`                 |
| `dependency_injection` | dotnet/runtime    | `src/libraries/Microsoft.Extensions.DependencyInjection/src/`                                                       | `packages/extensions/lib/src/dependency_injection/`    |
| `logging`              | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Logging/src/`                                                                   | `packages/extensions/lib/src/logging/`                 |
| `configuration`        | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Configuration/src/`                                                             | `packages/extensions/lib/src/configuration/`           |
| `options`              | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Options/src/`                                                                   | `packages/extensions/lib/src/options/`                 |
| `caching`              | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Caching.Memory/src/`                                                            | `packages/extensions/lib/src/caching/`                 |
| `http`                 | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Http/src/`                                                                      | `packages/extensions/lib/src/http/`                    |
| `primitives`           | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Primitives/src/`                                                                | `packages/extensions/lib/src/primitives/`              |
| `file_providers`       | dotnet/runtime    | `src/libraries/Microsoft.Extensions.FileProviders.Physical/src/`                                                    | `packages/extensions/lib/src/file_providers/`          |
| `file_system_globbing` | dotnet/runtime    | `src/libraries/Microsoft.Extensions.FileSystemGlobbing/src/`                                                        | `packages/extensions/lib/src/file_system_globbing/`    |
| `diagnostics`          | dotnet/runtime    | `src/libraries/Microsoft.Extensions.Diagnostics/src/`                                                               | `packages/extensions/lib/src/diagnostics/`             |
| `ai`                   | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Abstractions/` and `src/Libraries/Microsoft.Extensions.AI/`                 | `packages/extensions/lib/src/ai/`                      |
| `vector_data`          | dotnet/extensions | `src/Libraries/Microsoft.Extensions.VectorData.Abstractions/`                                                       | `packages/extensions/lib/src/vector_data/`             |
| `ai_evaluation`        | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.Evaluation/` plus `.NLP`, `.Quality`, `.Reporting`, `.Safety`, `.Console`, `.Reporting.Azure` | `packages/extensions/lib/src/ai/evaluation/`           |
| `ai_openai`            | dotnet/extensions | `src/Libraries/Microsoft.Extensions.AI.OpenAI/`                                                                     | `packages/extensions/lib/src/ai/open_ai/`              |

The last two rows were added 2026-08-13, after an audit found both areas
ported but outside every scope row — so they had never been checked. They are
in `ai/` but are *separate upstream libraries*; the `ai` row covers only
`Microsoft.Extensions.AI.Abstractions` + `Microsoft.Extensions.AI`. `all`
includes them. Their scope decisions are still open — see the drift ledger's
first open priority before reporting their gaps as drift.

All paths in this table were verified against the GitHub Contents API on
2026-07-06. Layout rules (do not deviate from them):

- dotnet/runtime: lowercase `src/libraries/`, and the C# sources sit in a
  `src/` subfolder — the path **ends in `/src/`**.
- dotnet/extensions: capital `src/Libraries/`, and the C# sources sit
  directly in the library folder — there is **no `/src/` suffix**. Appending
  one returns 404; never "fix" a URL by adding it.
- `diagnostics` intentionally maps to dotnet/runtime (metrics types), not the
  dotnet/extensions package of the same name.
- AI Realtime types live inside the two AI library folders above and are
  ported under `packages/extensions/lib/src/ai/realtime/`.

> Note: `packages/extensions/lib/src/system/` holds local Dart utility types
> (disposables, threading, string helpers) with no direct upstream counterpart.
> Skip it.

---

# Incremental mode (`/drift`, `/drift sync`)

## Step I1 — Collect upstream commits since the pins

Read both `upstream-sync(...)` pins from `drift-ledger.md`. Then:

**dotnet/extensions** (one query — `src/Libraries` covers every in-scope row):

```bash
curl -s "https://api.github.com/repos/dotnet/extensions/commits?path=src/Libraries&since=<extensions pin date>&per_page=100"
```

**dotnet/runtime** (one query per in-scope path — the commits API takes a
single `path`; loop the 11 dotnet/runtime rows in the table above, then
dedupe by SHA):

```bash
curl -s "https://api.github.com/repos/dotnet/runtime/commits?path=<C# source path>&since=<runtime pin date>&per_page=100"
```

Drop the pin commits themselves from each result (`since` is inclusive).
If both lists are empty, report "in sync as of <pin dates>" and stop.

## Step I2 — Classify each commit

For each new commit, fetch its file list
(`https://api.github.com/repos/<repo>/commits/<sha>` includes per-file paths
and patches) and keep only files under in-scope paths. Classify:

- **Out of scope** — only touches tests/csproj/build files, or libraries the
  ledger rules N/A (`.Console`, `.Reporting.Azure`, `AI.OpenAI`). One line,
  move on.
- **Applicable** — read the patch (fetch full files via the raw URL when the
  patch lacks context) and the corresponding Dart code, then decide:
  - **port** — behavior/API change the Dart port should mirror,
  - **already covered** — the port already behaves this way (say why),
  - **skip (ledger)** — covered by the ledger's N/A table or an open-priority
    scope decision (count as suppressed),
  - **skip (propose)** — you judge it not applicable per `porting.md` (e.g.
    .NET-only machinery); needs a new ledger N/A entry recording that.

## Step I3 — Report (both incremental modes)

Produce a table per upstream repo: PR#/sha, date, one-line summary,
subsystem, classification, and for "port" items a one-line sketch of the
Dart change. Then totals and the suppressed count. In plain `/drift` mode,
stop here — do not edit code (advancing the pins alone is allowed when
everything was out of scope, but say you did).

## Step I4 — Sync (only `/drift sync`)

1. Work on a branch (`drift/sync-<YYYY-MM-DD>`), never directly on `main`
   (in an environment that already put you on a work branch, use that).
2. Port each "port" item per `porting.md`. Add or extend tests mirroring
   upstream's where they exist.
3. Record every "skip (propose)" decision in the ledger's N/A table, and
   update subsystem status rows the sync touched.
4. Advance both `upstream-sync(...)` pins to the newest commit reviewed per
   repo — even when everything was skipped, so the next run starts here.
5. Verify:
   ```bash
   cd packages/extensions && dart pub get && dart analyze && dart test
   cd ../extensions_flutter && flutter pub get && flutter analyze && flutter test
   ```
6. **Downstream ripple:** `package:extensions` is consumed by
   `jamiewest/agents` (which ports the agent-framework built on
   Microsoft.Extensions.AI upstream). If the sync changes public API —
   especially under `lib/src/ai/` — check the sibling checkout
   `~/Developer/agents` (`cd packages/agents && dart analyze` with a path
   override to this repo) when available; otherwise state the unverified
   ripple in the PR body. CI's downstream-canary job also checks this.
7. Commit with a body itemizing each ported upstream PR# and each recorded
   skip, push the branch, and open a PR with `gh pr create`. Do not merge it.

---

# Full audit mode (`/drift full`, `/drift <subsystem>`)

## Step 1 — Discover C# source structure via targeted Contents API calls

Do NOT fetch the full recursive tree for `dotnet/runtime` — it contains tens of
thousands of files and the response will be truncated. Use the Contents API
targeted to each subsystem's source directory instead.

### URL templates

- dotnet/runtime:
  `https://api.github.com/repos/dotnet/runtime/contents/<C# source path>`
- dotnet/extensions:
  `https://api.github.com/repos/dotnet/extensions/contents/<C# source path>`

### Per-subsystem fetch procedure

For each subsystem directory in scope, fetch the Contents API URL constructed
from the template above. The response is a JSON array; each element has:
- `name` — filename or directory name
- `type` — `"file"` or `"dir"`
- `path` — full repo-relative path
- `url` — pre-built API URL for that item's own listing

For every element with `"type": "dir"`, fetch its `url` to get the next level.
Repeat for one additional level of nesting (two hops total is sufficient for
these libraries; deeper nesting is rare).

> Note: `dotnet/extensions` uses `src/Libraries/` (capital L). If a URL returns
> 404, fetch the repo root listing to discover the actual directory structure.

For the `ai` subsystem, perform two root fetches and merge the results:
1. `src/Libraries/Microsoft.Extensions.AI.Abstractions/`
2. `src/Libraries/Microsoft.Extensions.AI/`

Collect only `.cs` files. Exclude:
- Test files: path contains `Test`, `.Tests.`, or `testhost`
- Generated files: `*.g.cs`, `*.Designer.cs`
- Build artefacts: path segment is `obj` or `bin`

Record for each file: `(upstream_repo, repo_relative_path, inferred_type_name)`
where the type name is the filename without `.cs`.

## Step 2 — Map to Dart files and find missing types

For each collected C# type:

1. Convert PascalCase → snake_case filename using these rules:
   - Treat all-caps acronyms as a single token: `AI` → `ai`, `HTTP` → `http`,
     `DI` → `di`, `JSON` → `json`, `URI` → `uri`.
   - Insert `_` before every uppercase letter that follows a lowercase letter
     or follows the end of an acronym token.
   - Examples: `AIContent` → `ai_content.dart`,
     `ChatClientBuilder` → `chat_client_builder.dart`,
     `ILoggerFactory` → `i_logger_factory.dart`.

2. Check existence in the Dart folder for this subsystem:
   ```bash
   find packages/extensions/lib/src/<dart_subfolder> -name "<snake_case>.dart"
   ```

3. If no file was found, fall back to a whole-tree declaration search before
   concluding anything — Dart files here often hold several classes, and some
   upstream sub-packages are merged into sibling folders:
   ```bash
   grep -rn "class <TypeName>\b\|typedef <TypeName>\b\|enum <TypeName>\b\|extension <TypeName>\b" \
     packages/extensions/lib/src/ --include="*.dart"
   ```

4. Classify:
   - File or declaration found → **Ported**
   - Neither found → **Not Yet Ported**

## Step 2.5 — Filter through the drift ledger

Read `.claude/rules/dart/drift-ledger.md`. Remove from the **Not Yet Ported**
list every type that appears in its "Intentionally not ported (N/A list)"
table — those are deliberate port decisions, not drift. Do not re-litigate
them. If the user explicitly asks, list them separately under "intentionally
not ported"; otherwise omit them from the report entirely.

## Step 3 — API surface gap check (sample-based)

For up to 10 **Ported** types (prioritise types in `Abstractions` namespaces or
named `I<Foo>`), fetch the C# source using the raw URL for the appropriate repo:

- dotnet/runtime:
  `https://raw.githubusercontent.com/dotnet/runtime/main/<repo_relative_path>`
- dotnet/extensions:
  `https://raw.githubusercontent.com/dotnet/extensions/main/<repo_relative_path>`

From the C# source, extract all public member names (methods, properties,
events, constructors). Then read the Dart counterpart.

Flag any C# public member that:
- Has no counterpart in the Dart file, AND
- Is not a trivially collapsed overload (C# multiple overloads → single Dart
  method with named parameters), AND
- Is not an operator, destructor, or explicit interface implementation.

Do not flag members renamed to follow Dart conventions (e.g. `IsEmpty` →
`isEmpty`).

### C# primary constructors

Upstream — especially `dotnet/extensions` AI — declares constructors in the
class header: `internal sealed class FunctionInvocationLogger(ILogger logger)`.
Read those header parameters as the constructor signature (a parameter is a
field only where the body captures it) and compare them against the Dart
constructor.

Dart has primary constructors too, as of **3.13**
(`class Point(final int x, final int y);`), and the workspace floor is
`sdk: ^3.13.0` (raised 2026-08-16), so both Dart forms are legal. So:

- **Either Dart constructor form carrying the same parameters is a correct
  port of a C# primary constructor — never report it as drift**, and do not
  propose rewriting conventional constructors into primary-constructor
  syntax; there is no conversion campaign.
- Only report a gap when the *parameters themselves* differ. Note that a
  named initializing formal `this._bar` surfaces to callers as `bar:` (3.13
  strips the underscore), so compare against the public name.
- `.claude/rules/dart/porting.md` § "Primary constructors" is the
  authoritative version of this note.

## Step 4 — Implementation debt scan

```bash
grep -rn "TODO\|FIXME\|HACK\|throw UnimplementedError\|throw UnsupportedError" \
  packages/extensions/lib/src/ --include="*.dart"
```

Group by file. Show workspace-relative paths and line numbers.
Total count: N

## Step 5 — Static analysis

Run from the package directory, and `pub get` first — analyzing from the
workspace root against a stale package config reports every
`package:extensions/…` import as `uri_does_not_exist` and buries the run in
thousands of phantom errors:

```bash
cd packages/extensions && dart pub get && dart analyze
```

Show all errors, then warnings. Record the total count of each. If the count
is in the thousands and the errors are `uri_does_not_exist` /
`undefined_identifier` on the package's own imports, that is the stale-config
artefact — fix the setup and re-run rather than reporting it.

Note that a clean `dart analyze` does not prove style conformance: verify the
linter config itself is live (see the 80-char check in Step 7) before
concluding the repo is clean.

## Step 6 — Test gap check

```bash
find packages/extensions/lib/src -name "*.dart" ! -name "*.g.dart" \
  | while read f; do
      base=$(basename "$f" .dart)
      test_file=$(find packages/extensions/test -name "${base}_test.dart" \
                   2>/dev/null | head -1)
      [ -z "$test_file" ] && echo "NO_TEST: $f"
    done
```

From the results, exclude pure re-export or barrel files (heuristic: fewer than
20 non-blank lines). Report the remaining list and the ratio
`files_with_test / total_source_files`.

## Step 7 — Conformance spot-check

```bash
# I-prefixed abstract interface names (Dart uses implicit interfaces; IFoo
# names are a code smell unless mirroring a C# name intentionally — the
# file_system_globbing internals are a documented exception, see the N/A
# list in .claude/rules/dart/drift-ledger.md)
grep -rn "^abstract interface class I[A-Z]" \
  packages/extensions/lib/src/ --include="*.dart"

# print() calls (use package:logging or dart:developer log() instead)
grep -rn "^\s*print(" packages/extensions/lib/src/ --include="*.dart"

# Lines > 80 characters (sample up to 20 violations). Use grep, not awk:
# awk positional variables get clobbered by this command's argument
# substitution, and NR is cumulative across files.
grep -rnE ".{81,}" packages/extensions/lib/src/ --include="*.dart" | head -20

# Public declarations missing a dartdoc comment
grep -rn "^  [a-zA-Z]" packages/extensions/lib/src/ --include="*.dart" \
  | grep -v "^\s*/\{3\}" | head -20
```

### Example-reference integrity

Public API dartdoc references runnable example regions via dartdoc's
`{@example /example/<file>.dart#<region>}` directive (see
`.claude/rules/dart/porting.md` § "Examples and doc references"). A renamed or
deleted region silently breaks the rendered docs, so verify every reference
resolves:

Never name a shell variable `path` in these snippets — in zsh (the shell used
here) `path` is tied to `PATH`, and assigning it wipes the command search path
mid-loop, producing bogus `command not found: sort` errors.

```bash
# Every referenced (file, region) pair
grep -rhoE "\{@example [^}]+\}" packages/extensions/lib/ --include="*.dart" \
  | sed -E 's/\{@example +([^ }#]+)#?([^ }]*).*/\1 \2/' | sort -u \
  | while read -r exfile region; do
      target="packages/extensions${exfile}"
      [ -f "$target" ] || { echo "MISSING_FILE: $exfile"; continue; }
      [ -z "$region" ] && continue
      grep -q "#region $region\b" "$target" \
        || echo "MISSING_REGION: $exfile#$region"
    done

# Regions defined but never referenced (dead example code)
grep -rhoE "#region [a-z0-9_]+" packages/extensions/example/ \
  | sort -u | while read -r _ region; do
      grep -rq "#$region}" packages/extensions/lib/ --include="*.dart" \
        || echo "UNREFERENCED_REGION: $region"
    done
```

`dart doc` is the authoritative check — it fails the run on an unclosed
`#region` and warns `example file not found` on a bad path:

```bash
cd packages/extensions && dart doc --output /tmp/drift-docs
```

A path without a leading `/` is also a defect — dartdoc resolves it against
`lib/` and warns `example file not found`.

## Report

Be concise — list findings; do not explain every item.

### Upstream Drift

**Not yet ported** (grouped by subsystem)
- `<Subsystem>`: `<CSharpTypeName>` — `<repo_relative_path>`

**API surface gaps** (for sampled types)
- `<DartFile>`: missing `<CSharpMemberName>`, `<CSharpMemberName>`, …

### Implementation Debt

Grouped by file, workspace-relative paths with line numbers.
Total stub/TODO count: N

### Static Analysis

Errors (N):
- …

Warnings (N):
- …

### Test Gaps

Files without a test (excluding barrels):
- …

Coverage ratio: X / Y source files have a corresponding `*_test.dart`.

### Conformance

- `IFoo`-style names: …
- `print()` usage: …
- Line-length violations (sample): …
- Missing dartdoc (sample): …
- Broken `{@example}` references / unreferenced regions: …

### Summary

- **Scope checked:** `$ARGUMENTS` (expanded to: hosting, dependency_injection, …)
- **Upstream repos:** dotnet/runtime, dotnet/extensions (as applicable)
- **Severity:** Low / Medium / High (overall judgment)
- **Top 3 actions** to reduce drift, most impactful first:
  1. …
  2. …
  3. …

For each recommended action, closing the gap should follow
`.claude/rules/dart/porting.md` (type-mapping matrix, naming rules, and the
list of constructs that must not be ported).

## Step 8 — Update the drift ledger

After producing the report, update `.claude/rules/dart/drift-ledger.md` so
the next run starts from accurate state:

1. In the **Subsystem status** table, set "Last audited" to today's date for
   every subsystem in scope, and revise the "Status" cell if the audit
   changed it (e.g. a gap was closed or newly discovered).
2. If the audit established that a type cannot or should not be ported, add
   it to the **Intentionally not ported** table with a one-line reason.
3. Rewrite the **Open priorities** list to match the report's "Top 3
   actions" plus any remaining known items, most impactful first.
4. A full audit that leaves a subsystem gap-free may also advance the
   `upstream-sync(...)` pin for that subsystem's repo, if the whole repo
   scope was covered.

Do not delete N/A entries or unrelated subsystem rows; this file is
cumulative state shared across sessions.
