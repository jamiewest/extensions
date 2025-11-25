import '../configuration/configuration.dart';
import '../primitives/change_token.dart';
import 'options.dart';
import 'options_change_token_source.dart';
import 'options_monitor.dart';

/// Creates [ChangeToken]s so that [OptionsMonitor] gets
/// notified when [Configuration] changes.
class ConfigurationChangeTokenSource<TOptions>
    extends OptionsChangeTokenSource<TOptions> {
  final Configuration _config;
  final String _name;

  ConfigurationChangeTokenSource({
    required Configuration config,
    String? name,
  })  : _config = config,
        _name = name ?? Options.defaultName;

  /// The name of the option instance being changed.
  @override
  IChangeToken getChangeToken() => _config.getReloadToken();

  /// Returns the reloadToken from the [Configuration].
  @override
  String get name => _name;
}
