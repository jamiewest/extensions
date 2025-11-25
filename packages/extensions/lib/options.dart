/// Provides types used for implementing the options pattern.
library options;

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
