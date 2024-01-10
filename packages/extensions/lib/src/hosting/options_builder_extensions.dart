import '../dependency_injection/service_collection_service_extensions.dart';
import '../options/validate_on_start.dart';

import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/options.dart';
import '../options/options_builder.dart';
import '../options/options_monitor.dart';
import '../options/options_service_collection_extensions.dart';
import '../options/startup_validator_options.dart';

/// Extension methods for adding configuration related options services to 
/// the DI container via [OptionsBuilder{TOptions}].
extension OptionsBuilderExtensions<TOptions> on OptionsBuilder<TOptions> {
  OptionsBuilder<TOptions> validateOnStart() {
    services.addTransient<StartupValidator>(
      (services) => StartupValidator(
        validators:
            services.getRequiredService<Options<StartupValidatorOptions>>(),
      ),
    );

    services
        .addOptions<StartupValidatorOptions>(
      () => StartupValidatorOptions(),
    )
        .configure1<OptionsMonitor<TOptions>>((vo, options) {
      vo.validators[(TOptions, name)] = () => options.get(name);
    });

    return this;
  }
}
