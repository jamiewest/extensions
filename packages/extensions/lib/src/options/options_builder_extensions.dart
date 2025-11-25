import '../dependency_injection/service_collection_service_extensions.dart';
import '../dependency_injection/service_provider_service_extensions.dart';
import 'options.dart';
import 'options_builder.dart';
import 'options_monitor.dart';
import 'options_service_collection_extensions.dart';
import 'startup_validator_options.dart';
import 'validate_on_start.dart';

extension OptionsBuilderExtensions<TOptions> on OptionsBuilder<TOptions> {
  OptionsBuilder<TOptions> validateOnStart() {
    services.addTransient<StartupValidator>(
      (services) => StartupValidator(
        validators: services.getService<Options<StartupValidatorOptions>>()!,
      ),
    );
    services
        .addOptions<StartupValidatorOptions>(StartupValidatorOptions.new)
        .configure1<OptionsMonitor<TOptions>>((vo, options) => vo.validators);

    return this;
  }
}
