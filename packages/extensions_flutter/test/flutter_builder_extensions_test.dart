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

class _WrapperWidget extends StatelessWidget {
  const _WrapperWidget({required this.child, required this.label});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(children: [Text(label), child]),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlutterBuilderExtensions', () {
    test('useApp registers root widget correctly', () {
      final services = ServiceCollection()
        ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
        ..addLogging()
        ..addFlutter(
          (flutter) => flutter.runApp((_) => const Text('Root Widget')),
        );

      final provider = services.buildServiceProvider();
      final widget = provider.getRequiredService<Widget>();

      // The widget should be wrapped in FlutterLifecycleObserver
      expect(widget, isA<FlutterLifecycleObserver>());
      final observer = widget as FlutterLifecycleObserver;
      expect(observer.child, isA<Text>());
      expect((observer.child as Text).data, 'Root Widget');
    });

    test('useApp wraps root widget with registered widgets', () {
      final services = ServiceCollection()
        ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
        ..addLogging()
        ..addFlutter((flutter) {
          flutter.wrapWith(
            (sp, child) => _WrapperWidget(label: 'Wrapper 1', child: child),
          );
          flutter.wrapWith(
            (sp, child) => _WrapperWidget(label: 'Wrapper 2', child: child),
          );
          flutter.runApp((_) => const Text('Root Widget'));
        });

      final provider = services.buildServiceProvider();
      final widget = provider.getRequiredService<Widget>();

      // Outermost wrapper is Wrapper 1
      expect(widget, isA<_WrapperWidget>());
      final wrapper1 = widget as _WrapperWidget;
      expect(wrapper1.label, 'Wrapper 1');

      // Next is Wrapper 2
      expect(wrapper1.child, isA<_WrapperWidget>());
      final wrapper2 = wrapper1.child as _WrapperWidget;
      expect(wrapper2.label, 'Wrapper 2');

      // Then FlutterLifecycleObserver
      expect(wrapper2.child, isA<FlutterLifecycleObserver>());
      final observer = wrapper2.child as FlutterLifecycleObserver;

      // Finally the root Text widget
      expect(observer.child, isA<Text>());
      expect((observer.child as Text).data, 'Root Widget');
    });

    test('root widget is built last and becomes innermost child', () {
      var buildOrder = <String>[];

      final services = ServiceCollection()
        ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
        ..addLogging()
        ..addFlutter((flutter) {
          flutter.wrapWith((sp, child) {
            buildOrder.add('Wrapper 1');
            return _WrapperWidget(label: 'Wrapper 1', child: child);
          });
          flutter.wrapWith((sp, child) {
            buildOrder.add('Wrapper 2');
            return _WrapperWidget(label: 'Wrapper 2', child: child);
          });
          flutter.runApp((_) {
            buildOrder.add('Root');
            return const Text('Root Widget');
          });
        });

      final provider = services.buildServiceProvider();
      provider.getRequiredService<Widget>();

      // Root should be built first, then wrappers in reverse order
      // (FlutterLifecycleObserver is built but doesn't add to the list)
      expect(buildOrder, ['Root', 'Wrapper 2', 'Wrapper 1']);
    });

    test('useApp provides widget to FlutterLifetime', () {
      final services = ServiceCollection()
        ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
        ..addLogging()
        ..addFlutter(
          (flutter) => flutter.runApp((_) => const Text('Root Widget')),
        );

      final provider = services.buildServiceProvider();
      final lifetime = provider.getRequiredService<HostLifetime>();

      expect(lifetime, isA<FlutterLifetime>());
    });

    test('wrapWith can access services', () {
      final services = ServiceCollection()
        ..addSingleton<String>((_) => 'Test Value')
        ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
        ..addLogging()
        ..addFlutter((flutter) {
          flutter.wrapWith((sp, child) {
            final value = sp.getRequiredService<String>();
            return _WrapperWidget(label: value, child: child);
          });
          flutter.runApp((_) => const Text('Root Widget'));
        });

      final provider = services.buildServiceProvider();
      final widget = provider.getRequiredService<Widget>();

      expect(widget, isA<_WrapperWidget>());
      expect((widget as _WrapperWidget).label, 'Test Value');
    });

    test('useApp builder receives service provider', () {
      final services = ServiceCollection()
        ..addSingleton<String>((_) => 'Service Value')
        ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
        ..addLogging()
        ..addFlutter(
          (flutter) => flutter.runApp((sp) {
            final value = sp.getRequiredService<String>();
            return Text(value);
          }),
        );

      final provider = services.buildServiceProvider();
      final widget = provider.getRequiredService<Widget>();

      // The widget should be wrapped in FlutterLifecycleObserver
      expect(widget, isA<FlutterLifecycleObserver>());
      final observer = widget as FlutterLifecycleObserver;
      expect(observer.child, isA<Text>());
      expect((observer.child as Text).data, 'Service Value');
    });

    test(
      'multiple registered widgets are applied in reverse registration order',
      () {
        final services = ServiceCollection()
          ..addSingleton<HostEnvironment>((_) => _TestHostEnvironment())
          ..addLogging()
          ..addFlutter((flutter) {
            flutter.wrapWith(
              (sp, child) => _WrapperWidget(label: 'First', child: child),
            );
            flutter.wrapWith(
              (sp, child) => _WrapperWidget(label: 'Second', child: child),
            );
            flutter.wrapWith(
              (sp, child) => _WrapperWidget(label: 'Third', child: child),
            );
            flutter.runApp((_) => const Text('Root'));
          });

        final provider = services.buildServiceProvider();
        final widget = provider.getRequiredService<Widget>();

        // Should be wrapped as: First(Second(Third(FlutterLifecycleObserver(Root))))
        expect(widget, isA<_WrapperWidget>());
        final first = widget as _WrapperWidget;
        expect(first.label, 'First');

        expect(first.child, isA<_WrapperWidget>());
        final second = first.child as _WrapperWidget;
        expect(second.label, 'Second');

        expect(second.child, isA<_WrapperWidget>());
        final third = second.child as _WrapperWidget;
        expect(third.label, 'Third');

        expect(third.child, isA<FlutterLifecycleObserver>());
        final observer = third.child as FlutterLifecycleObserver;

        expect(observer.child, isA<Text>());
        expect((observer.child as Text).data, 'Root');
      },
    );
  });
}
