import 'package:firebase_core/firebase_core.dart';

class FlutterFirebaseOptions extends FirebaseOptions {
  const FlutterFirebaseOptions({
    required super.apiKey,
    required super.appId,
    required super.messagingSenderId,
    required super.projectId,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
  });

  final bool enableAnalytics;

  final bool enableCrashReporting;
}
