import '../dependency_injection/service_provider_service_extensions.dart';
import '../options/options.dart';
import '../options/options_builder.dart';
import '../options/options_monitor.dart';
import '../options/options_service_collection_extensions.dart';
import 'service_collection_hosted_service_extensions.dart';
import 'validation_hosted_service.dart';
import 'validator_options.dart';

extension OptionsBuilderExtensions<TOptions> on OptionsBuilder<TOptions> {
  OptionsBuilder<TOptions> validateOnStart() {
    const options = ValidatorOptions.new;

    services.addHostedService<ValidationHostedService>(
      (s) => ValidationHostedService(
        s.getRequiredService<Options<ValidatorOptions>>(),
      ),
    );
    services
        .addOptions<ValidatorOptions>(options)
        .configure1<OptionsMonitor<TOptions>>(
          (vo, options) => vo.validators[TOptions] = () => options.get(name),
        );

    return this;
  }
}
