import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_builder_options.dart';

class FirebaseService extends BackgroundService {
  final OptionsMonitor<FirebaseBuilderOptions> _options;

  FirebaseService(OptionsMonitor<FirebaseBuilderOptions> options)
      : _options = options;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    await Firebase.initializeApp(
      options: _options.currentValue.options,
    );
  }
}
