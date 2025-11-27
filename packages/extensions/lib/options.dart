/// Provides types for implementing the options pattern for strongly-typed
/// configuration.
///
/// This library enables the options pattern inspired by
/// Microsoft.Extensions.Options, allowing applications to bind configuration
/// sections to strongly-typed objects with validation and change notification.
///
/// ## Basic Usage
///
/// Register and use options:
///
/// ```dart
/// services
///   ..configure<MyOptions>((options) {
///     options.setting1 = 'value1';
///     options.setting2 = 42;
///   });
///
/// final options = provider.getRequiredService<Options<MyOptions>>();
/// print(options.value.setting1);
/// ```
///
/// ## Configuration Binding
///
/// Bind configuration sections to options:
///
/// ```dart
/// services.configure<MyOptions>(
///   configuration.getSection('MySettings'),
/// );
/// ```
///
/// ## Named Options
///
/// Register multiple option instances with different names:
///
/// ```dart
/// services
///   ..configure<DbOptions>('Primary', (opts) => opts.conn = 'conn1')
///   ..configure<DbOptions>('Secondary', (opts) => opts.conn = 'conn2');
///
/// final options = provider.getRequiredService<OptionsSnapshot<DbOptions>>();
/// final primaryDb = options.get('Primary');
/// ```
///
/// ## Options Monitoring
///
/// React to configuration changes at runtime:
///
/// ```dart
/// final monitor = provider.getRequiredService<OptionsMonitor<MyOptions>>();
/// monitor.onChange((opts, name) {
///   print('Options changed: $name');
/// });
/// ```
library;

export 'src/options/configuration_change_token_source.dart';
export 'src/options/configure_named_options.dart' show ConfigureNamedOptions;
export 'src/options/configure_options.dart' show ConfigureOptions;
export 'src/options/options.dart' show Options;
export 'src/options/options_change_token_source.dart'
    show OptionsChangeTokenSource;
export 'src/options/options_factory.dart' show OptionsFactory;
export 'src/options/options_monitor.dart' show OptionsMonitor;
export 'src/options/options_monitor_cache.dart' show OptionsMonitorCache;
export 'src/options/options_service_collection_extensions.dart'
    show OptionsServiceCollectionExtensions;
export 'src/options/options_snapshot.dart' show OptionsSnapshot;
export 'src/options/post_configure_options.dart' show PostConfigureOptions;
export 'src/options/validate_options.dart';
export 'src/options/validate_options_result.dart' show ValidateOptionsResult;
