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

  testWidgets('Print widget tree to verify FlutterLifecycleObserver',
      (WidgetTester tester) async {
    final services = ServiceCollection()
      ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
      ..addLogging()
      ..addFlutter(
        (flutter) => flutter.useApp(
          (_) => const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('My App'),
          ),
        ),
      );

    final provider = services.buildServiceProvider();
    final widget = provider.getRequiredService<Widget>();

    await tester.pumpWidget(widget);

    // This will print the entire widget tree to console
    debugDumpApp();

    // You should see FlutterLifecycleObserver in the output
    expect(find.byType(FlutterLifecycleObserver), findsOneWidget);
  });
}
