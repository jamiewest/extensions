import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestHostEnvironment implements HostEnvironment {
  @override
  String applicationName = 'test-app';

  @override
  String contentRootPath = '/tmp';

  @override
  FileProvider? contentRootFileProvider;

  @override
  String environmentName = 'test';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FlutterLifecycleObserver is in the widget tree', (
    WidgetTester tester,
  ) async {
    // Build the widget tree through DI
    final services = ServiceCollection()
      ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
      ..addLogging()
      ..addFlutter(
        (flutter) => flutter.runApp(
          (_) => const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('My App'),
          ),
        ),
      );

    final provider = services.buildServiceProvider();
    final widget = provider.getRequiredService<Widget>();

    // Pump the widget tree
    await tester.pumpWidget(widget);

    // Verify FlutterLifecycleObserver is in the tree
    expect(find.byType(FlutterLifecycleObserver), findsOneWidget);

    // Verify our app widget is also there
    expect(find.text('My App'), findsOneWidget);
  });

  testWidgets('FlutterLifecycleObserver wraps the app widget', (
    WidgetTester tester,
  ) async {
    final services = ServiceCollection()
      ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
      ..addLogging()
      ..addFlutter(
        (flutter) => flutter.runApp(
          (_) => const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Test Content'),
          ),
        ),
      );

    final provider = services.buildServiceProvider();
    final widget = provider.getRequiredService<Widget>();

    await tester.pumpWidget(widget);

    // Find the observer widget
    final observerFinder = find.byType(FlutterLifecycleObserver);
    expect(observerFinder, findsOneWidget);

    // Get the observer widget
    final observer = tester.widget<FlutterLifecycleObserver>(observerFinder);

    // Verify it has the app as a child
    expect(observer.child, isA<Directionality>());

    // Verify the full content is rendered
    expect(find.text('Test Content'), findsOneWidget);
  });
}
