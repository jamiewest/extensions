// import '../../../primitives/change_token.dart';
// import '../../../shared/disposable.dart';
// import '../../configuration_provider.dart';
// import 'file_configuration_source.dart';

// /// Base class for file based [ConfigurationProvider].
// abstract class FileConfigurationProvider
//     implements ConfigurationProvider, IDisposable {
//   IDisposable? _changeTokenRegistration;
//   final FileConfigurationSource _source;

//   /// Initializes a new instance with the specified source
//   FileConfigurationProvider(FileConfigurationSource source) : _source = source {
//     if (_source.reloadOnChange && _source.fileProvider != null) {
//       _changeTokenRegistration = ChangeToken.onChange(
//         () => _source.fileProvider!.watch(_source.path!)!,
//         load,
//       );
//     }
//   }

//   /// The source settings for this provider.
//   FileConfigurationSource get source => _source;

//   /// Generates a string representing this provider name and relevant details.
//   @override
//   String toString() =>
//       '${this.runtimeType.toString()} for \'${source.path}\' (${source.optional ? 'Optional' : 'Required'})';
// }
