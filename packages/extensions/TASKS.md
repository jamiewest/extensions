# Tasks

## Fix opaque DI exception error messages

Two bugs in the error-reporting path make crashes from the dependency injection
container completely undiagnosable in production logs. Both need fixing and
regression tests.

---

### Bug 1 — `ExceptionBase` missing `toString()` override

**File:** `lib/src/system/exceptions/exception_base.dart`

`ExceptionBase` implements `Exception` but never overrides `toString()`. Dart's
default `Object.toString()` returns `Instance of 'ClassName'`, so any exception
that extends `ExceptionBase` (e.g. `InvalidOperationException`) logs as
`Instance of 'InvalidOperationException'` — the `message` field is silently
discarded.

**Fix already applied** — the following override was added at the bottom of
`ExceptionBase`:

```dart
@override
String toString() => '$_typeName: $message';
```

**Action:** Verify the fix is present, then add a unit test in
`test/system/exceptions/` (create the directory if it doesn't exist) confirming
that `InvalidOperationException('some message').toString()` contains the message
string and does not equal `Instance of 'InvalidOperationException'`.

---

### Bug 2 — Wrong type name in "service not found" error message

**File:** `lib/src/dependency_injection/service_provider_service_extensions.dart`
**Line:** 29

```dart
// Current (wrong):
message: 'No service for type \'${serviceType.runtimeType.toString()}\''
    ' has been registered.',

// Fixed:
message: 'No service for type \'$serviceType\' has been registered.',
```

`serviceType` is already a `Type` value. Calling `.runtimeType` on it returns
the meta-type `Type`, so the error message always reads
`No service for type 'Type' has been registered.` regardless of which service
is actually missing.

**Fix:** Replace `serviceType.runtimeType.toString()` with `serviceType` (Dart
will call `.toString()` automatically inside the string interpolation).

**Action:** Apply the fix, then add a unit test in
`test/dependency_injection/` confirming that requesting an unregistered service
produces an exception whose message contains the actual type name (not the
literal string `'Type'`).

---

### Verification

After both fixes:

```sh
dart analyze packages/extensions
dart test packages/extensions
```

Both commands must complete with no errors.
