import 'dart:collection';

import 'package:extensions/configuration.dart';

void main(List<String> args) {
  final switchMappings = LinkedHashMap<String, String>.from(
    <String, String>{
      '-k1': 'key1',
      '-k2': 'key2',
      '--alt3': 'key3',
      '--alt4': 'key4',
      '--alt5': 'key5',
      '--alt6': 'key6',
    },
  );

  final builder = ConfigurationBuilder()..addCommandLine(args, switchMappings);
  final config = builder.build();

  print('Key1: \'${config["Key1"]}\'');
  print('Key2: \'${config["Key2"]}\'');
  print('Key3: \'${config["Key3"]}\'');
  print('Key4: \'${config["Key4"]}\'');
  print('Key5: \'${config["Key5"]}\'');
  print('Key6: \'${config["Key6"]}\'');
}
