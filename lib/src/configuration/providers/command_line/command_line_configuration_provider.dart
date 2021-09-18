/*
  Make [args] internal only?
*/

import 'dart:collection';

import '../../configuration_provider.dart';

/// A command line based [ConfigurationProvider].
class CommandLineConfigurationProvider extends ConfigurationProvider
    with ConfigurationProviderMixin {
  LinkedHashMap<String, String>? _switchMappings;
  final Iterable<String> _args;

  /// Initializes a new instance.
  CommandLineConfigurationProvider(
    Iterable<String> args,
    LinkedHashMap<String, String>? switchMappings,
  ) : _args = args {
    if (switchMappings != null) {
      _switchMappings = _getValidatedSwitchMappingsCopy(switchMappings);
    }
  }

  /// The command line arguments.
  Iterable<String> get args => _args;

  /// Loads the configuration data from the command line args.
  @override
  void load() {
    var _data = LinkedHashMap<String, String>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );
    String? key;
    String? value;

    var enumerator = args.iterator;
    while (enumerator.moveNext()) {
      var currentArg = enumerator.current;
      var keyStartIndex = 0;

      if (currentArg.startsWith('--')) {
        keyStartIndex = 2;
      } else if (currentArg.startsWith('-')) {
        keyStartIndex = 1;
      } else if (currentArg.startsWith('/')) {
        // "/SomeSwitch" is equivalent to "--SomeSwitch" when interpreting switch mappings
        // So we do a conversion to simplify later processing
        currentArg = '--${currentArg.substring(1)}';
        keyStartIndex = 2;
      }

      var separator = currentArg.indexOf('=');
      if (separator < 0) {
        // If there is neither equal sign nor prefix in current
        // arugment, it is an invalid format
        if (keyStartIndex == 0) {
          // Ignore invalid formats
          continue;
        }
        // If the switch is a key in given switch mappings, interpret it
        if (_switchMappings != null) {
          if (_switchMappings!.containsKey(currentArg)) {
            key = _switchMappings![currentArg]!;
          } else if (keyStartIndex == 1) {
            continue;
          } else {
            key = currentArg.substring(keyStartIndex);
          }
        } else if (keyStartIndex == 1) {
          continue;
        } else {
          key = currentArg.substring(keyStartIndex);
        }

        var previousKey = enumerator.current;
        if (!enumerator.moveNext()) {
          // ignore missing values.
          continue;
        }
        value = enumerator.current;
      } else {
        var keySegment = currentArg.substring(0, separator);
        // If the switch is a key in given switch mappings, interpret it
        if (_switchMappings != null) {
          if (_switchMappings!.containsKey(keySegment)) {
            key = _switchMappings![keySegment]!;
            // If the switch starts with a single "-" and it
            // isn't in given mappings , it is an invalid usage
          } else if (keyStartIndex == 1) {
            throw Exception(
                'The short switch \'$currentArg\' is not defined in the switch mappings.');
          } else {
            key = currentArg.substring(keyStartIndex, separator);
          }
          value = currentArg.substring(separator + 1);
        } else if (keyStartIndex == 1) {
          throw Exception(
              'The short switch \'$currentArg\' is not defined in the switch mappings.');
        } else {
          key = currentArg.substring(keyStartIndex, separator);
        }

        value = currentArg.substring(separator + 1);
      }
      // Override value when key is duplicated.
      // So we always have the last argument win.
      _data[key] = value;
    }

    data = _data;
  }

  LinkedHashMap<String, String> _getValidatedSwitchMappingsCopy(
      LinkedHashMap<String, String> switchMappings) {
    var switchMappingsCopy = LinkedHashMap<String, String>(
      equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
      hashCode: (k) => k.toLowerCase().hashCode,
    );
    switchMappings.forEach((key, value) {
      if (!key.startsWith('-') && !key.startsWith('--')) {
        throw Exception('');
      }

      if (switchMappingsCopy.containsKey(key)) {
        throw Exception('');
      }

      switchMappingsCopy[key] = value;
    });

    return switchMappingsCopy;
  }
}
