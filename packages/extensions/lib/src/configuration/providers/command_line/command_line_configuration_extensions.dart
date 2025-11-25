import 'dart:collection';

import '../../configuration_builder.dart';
import '../../configuration_provider.dart';
import 'command_line_configuration_provider.dart';
import 'command_line_configuration_source.dart';

/// Extension methods for registering [CommandLineConfigurationProvider]
/// with [ConfigurationBuilder].
extension CommandLineConfigurationExtensions on ConfigurationBuilder {
  /// Adds a [CommandLineConfigurationProvider] [ConfigurationProvider]
  /// that reads configuration values from the command line.
  ///
  /// The values passed on the command line, in the `args` string array,
  /// should be a set of keys prefixed with two dashes ("--") and then values,
  /// separate by either the equals sign ("=") or a space (" ").
  ///
  /// A forward slash ("/") can be used as an alternative prefix, with either
  /// equals or space, and when using an equals sign the prefix can be left
  /// out altogether.
  ///
  /// There are five basic alternative formats for arguments:
  /// `key1=value1 --key2=value2 /key3=value3 --key4 value4 /key5 value5`.
  ///
  /// A simple console application that has five values.
  /// ```dart
  /// // dart example.dart key1=value1 --key2=value2 /key3=value3 --key4 value4 /key5 value5
  /// void main(List<String> args) {
  ///   final builder = ConfigurationBuilder()
  ///   ..addCommandLine(args);
  ///
  ///   final config = builder.build();
  ///   print('Key1: \'${config["Key1"]}\'');
  ///   print('Key2: \'${config["Key2"]}\'');
  ///   print('Key3: \'${config["Key3"]}\'');
  ///   print('Key4: \'${config["Key4"]}\'');
  ///   print('Key5: \'${config["Key5"]}\'');
  /// }
  /// ```
  ///
  /// The `switchMappings` allows additional formats for alternative short
  /// and alias keys to be used from the command line. Also see the basic
  /// version of `AddCommandLine` fornthe standard formats supported.
  ///
  /// Short keys start with a single dash ("-") and are mapped to the main key
  /// name (without prefix), and can be used with either equals or space. The
  /// single dash mappings are intended to be used for shorter alternative
  /// switches.
  ///
  /// Note that a single dash switch cannot be accessed directly, but must have
  /// a switch mapping defined and accessed using the full key. Passing an
  /// undefined single dash argument will cause as `FormatException`.
  ///
  /// There are two formats for short arguments:
  /// `-k1=value1 -k2 value2`.
  ///
  /// Alias key definitions start with two dashes ("--") and are mapped to the
  /// main key name (without prefix), and can be used in place of the normal
  /// key. They also work when a forward slash prefix is used in the command
  /// line (but not with the no prefix equals format).
  ///
  /// There are only four formats for aliased arguments:
  /// `--alt3=value3 /alt4=value4 --alt5 value5 /alt6 value6`.
  ///
  /// A simple console application that has two short and four alias switch
  /// mappings defined.
  /// ```dart
  /// // dart example.dart -k1=value1 -k2 value2 --alt3=value2 /alt4=value3 --alt5 value5 /alt6 value6
  /// void main(List<String> args) {
  ///   final switchMappings = LinkedHashMap<String, String>.from(
  ///     <String, String>{
  ///       '-k1': 'key1',
  ///       '-k2': 'key2',
  ///       '--alt3': 'key3',
  ///       '--alt4': 'key4',
  ///       '--alt5': 'key5',
  ///       '--alt6': 'key6',
  ///     },
  ///   );
  ///
  ///   final builder = ConfigurationBuilder()
  ///   ..addCommandLine(args, switchMappings);
  ///   final config = builder.build();
  ///
  ///   print('Key1: \'${config["Key1"]}\'');
  ///   print('Key2: \'${config["Key2"]}\'');
  ///   print('Key3: \'${config["Key3"]}\'');
  ///   print('Key4: \'${config["Key4"]}\'');
  ///   print('Key5: \'${config["Key5"]}\'');
  ///   print('Key6: \'${config["Key6"]}\'');
  /// }
  /// ```
  ConfigurationBuilder addCommandLine(Iterable<String> args,
      [LinkedHashMap<String, String>? switchMappings]) {
    add(
      CommandLineConfigurationSource(
        args: args,
        switchMappings: switchMappings,
      ),
    );
    return this;
  }
}
