# Examples

Every file here is a runnable program:

```bash
cd packages/extensions && dart run example/example_logging.dart
```

They are also the source of the code shown in the API docs. Blocks marked with
`// #region <name>` … `// #endregion` are pulled into dartdoc comments with the
`{@example}` directive, so a sample can never drift from code that compiles:

```dart
/// {@example /example/example_logging.dart#create_logger_factory}
```

Paths in the directive are package-root-relative (the leading `/` matters), and
lines ending in `// #hide` are dropped from the rendered block. See
`.claude/rules/dart/porting.md` § "Examples and doc references" for the
conventions, and run the reference-integrity check in `/drift` (Step 7) after
renaming a region — the region names are part of the docs contract.

## Index

| Example | Subsystem | Regions referenced by the docs |
|---|---|---|
| [example.dart](example.dart) | hosting | `default_host`, `lifetime_callbacks` |
| [example_hosting.dart](example_hosting.dart) | hosting | `build_and_start_host` |
| [example_background_service.dart](example_background_service.dart) | hosting | `register_background_service`, `background_service` |
| [example_dependency_injection.dart](example_dependency_injection.dart) | dependency_injection | `register_and_resolve` |
| [example_logging.dart](example_logging.dart) | logging | `create_logger_factory`, `log_at_levels` |
| [example_advanced_logging.dart](example_advanced_logging.dart) | logging | `typed_logger`, `logger_message_define` |
| [example_console_formatters.dart](example_console_formatters.dart) | logging | `simple_console_options` |
| [example_logging_configuration.dart](example_logging_configuration.dart) | logging + configuration | `logging_from_configuration` |
| [example_configuration.dart](example_configuration.dart) | configuration | `in_memory_configuration` |
| [example_options.dart](example_options.dart) | options | `configure_named_options`, `resolve_named_options` |
| [example_caching.dart](example_caching.dart) | caching | `memory_cache_basics`, `cache_expiration`, `cache_get_or_create` |
| [example_http_client_logging.dart](example_http_client_logging.dart) | http | `http_client_factory_setup`, `named_client_redaction`, `resolve_http_client` |
| [example_primitives.dart](example_primitives.dart) | primitives | `cancellation_change_token`, `composite_change_token`, `change_token_on_change` |
| [example_diagnostics.dart](example_diagnostics.dart) | diagnostics | `create_meter` |
| [example_file_providers.dart](example_file_providers.dart) | file_providers | `physical_file_provider` |
| [example_file_system_globbing.dart](example_file_system_globbing.dart) | file_system_globbing | `matcher_basic`, `matcher_include_exclude` |
| [example_ai.dart](example_ai.dart) | ai | `chat_client_pipeline`, `custom_chat_client`, `ai_function`, `ai_function_invoke`, `chat_streaming` |
| [example_vector_data.dart](example_vector_data.dart) | vector_data | `collection_definition`, `vector_store_filter`, `filtered_retrieval_options` |

Flutter integration has its own example, marked up the same way:

| Example | Package | Regions referenced by the docs |
|---|---|---|
| [example.dart](../../extensions_flutter/example/example.dart) | extensions_flutter | `add_flutter`, `root_widget` |

## Notes

- `example.dart` is the canonical entry point pub.dev shows on the package's
  Example tab — keep it at that exact path.
- The network-dependent example (`example_http_client_logging.dart`) prints
  request failures rather than throwing when offline; everything else runs
  without network access.
- `example_hosting.dart` and the hosted-service examples run until their host
  shuts down — `example.dart` and `example_background_service.dart` use the
  console lifetime, so stop them with Ctrl+C.
