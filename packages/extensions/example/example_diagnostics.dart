import 'package:extensions/dependency_injection.dart';
import 'package:extensions/diagnostics.dart';
import 'package:extensions/src/diagnostics/meter_factory.dart';
import 'package:extensions/src/diagnostics/metrics_builder_console_extensions.dart';
import 'package:extensions/src/diagnostics/metrics_builder_extensions.dart';
import 'package:extensions/src/diagnostics/metrics_service_extensions.dart';
import 'package:extensions/src/diagnostics/system/diagnostics.dart';
import 'package:extensions/src/diagnostics/system/meter_options.dart';

void main() async {
  // Example 1: Basic meter creation and usage
  print('=== Example 1: Basic Meter Creation ===');
  basicMeterExample();

  // Example 2: Using metrics with dependency injection
  print('\n=== Example 2: Metrics with Dependency Injection ===');
  await metricsWithDIExample();

  // Example 3: Custom metrics listener
  print('\n=== Example 3: Custom Metrics Listener ===');
  await customListenerExample();

  // Example 4: Meter with rules and filtering
  print('\n=== Example 4: Meter Rules and Filtering ===');
  await metricsWithRulesExample();

  print('\n=== Examples Complete ===');
}

/// Example 1: Creating and using a basic meter
void basicMeterExample() {
  // Create a meter options
  final meterOptions = MeterOptions('MyApplication')
    ..version = '1.0.0'
    ..tags = {
      'environment': 'development',
      'service': 'example-service',
    };

  // Create a meter
  final meter = Meter.from(meterOptions);

  print('Meter created:');
  print('  Name: ${meter.name}');
  print('  Version: ${meter.version}');
  print('  Tags: ${meter.tags}');

  // Cleanup
  meter.dispose();
  print('Meter disposed');
}

/// Example 2: Using metrics with dependency injection
Future<void> metricsWithDIExample() async {
  final services = ServiceCollection()
    ..addMetrics((builder) {
      // Add debug console listener for development
      builder.addDebugConsole();
    });

  final provider = services.buildServiceProvider();

  // Get the meter factory from DI
  final meterFactory = provider.getRequiredService<MeterFactory>();

  // Create meters using the factory
  final appMeter = meterFactory.create(
    MeterOptions('Application')..version = '1.0.0',
  );

  final requestMeter = meterFactory.create(
    MeterOptions('Requests')
      ..version = '1.0.0'
      ..tags = {'component': 'http'},
  );

  print('Created meters via DI:');
  print('  App Meter: ${appMeter.name} v${appMeter.version}');
  print('  Request Meter: ${requestMeter.name} v${requestMeter.version}');
  print('    Tags: ${requestMeter.tags}');

  print('Meters created successfully');
}

/// Example 3: Creating a custom metrics listener
Future<void> customListenerExample() async {
  final services = ServiceCollection()
    ..addMetrics((builder) {
      // Add our custom listener
      builder.addListener(_CustomMetricsListener());
    });

  final provider = services.buildServiceProvider();
  final meterFactory = provider.getRequiredService<MeterFactory>();

  final meter = meterFactory.create(MeterOptions('CustomExample'));

  print('Created meter with custom listener: ${meter.name}');
  print('Custom listener example complete');
}

/// Example 4: Using meter rules to filter which instruments are enabled
Future<void> metricsWithRulesExample() async {
  final services = ServiceCollection()
    ..addMetrics((builder) {
      builder
        ..addDebugConsole()
        // Enable specific meters by name
        ..enableMetrics(meterName: 'Application')
        ..enableMetrics(meterName: 'Performance')
        // Disable a specific meter
        ..disableMetrics(meterName: 'Debug');
    });

  final provider = services.buildServiceProvider();
  final meterFactory = provider.getRequiredService<MeterFactory>();

  // Create various meters
  final appMeter = meterFactory.create(MeterOptions('Application'));
  final perfMeter = meterFactory.create(MeterOptions('Performance'));
  final debugMeter = meterFactory.create(MeterOptions('Debug'));

  print('Meters created with rules:');
  print('  ${appMeter.name} - Should be enabled');
  print('  ${perfMeter.name} - Should be enabled');
  print('  ${debugMeter.name} - Should be disabled');

  print('Rules example complete');
}

/// A custom metrics listener implementation
class _CustomMetricsListener implements MetricsListener {
  @override
  String get name => 'CustomListener';

  @override
  void initialize(ObservableInstrumentsSource source) {
    print('[$name] Initialized');
  }

  @override
  (bool, Object?) instrumentPublished(Instrument instrument) {
    print('[$name] Instrument published: ${instrument.name}');
    print('  Meter: ${instrument.meter.name}');
    if (instrument.description != null) {
      print('  Description: ${instrument.description}');
    }
    if (instrument.unit != null) {
      print('  Unit: ${instrument.unit}');
    }

    // Return true to indicate we're listening to this instrument
    // Return false and null if we don't want to listen
    return (true, null);
  }

  @override
  MeasurementHandlers getMeasurementHandlers() {
    // Return empty handlers - in a real implementation,
    // you would provide handlers for different instrument types
    return MeasurementHandlers();
  }

  @override
  bool measurementsCompleted(Instrument instrument, Object? userState) {
    print('[$name] Measurements completed for: ${instrument.name}');
    return true;
  }
}
