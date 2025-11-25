import 'package:extensions_flutter/extensions_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('forwards hidden lifecycle state to lifetime', (tester) async {
    final lifetime = FlutterApplicationLifetime(NullLogger());
    final events = <String>[];

    lifetime.applicationHidden.add(() => events.add('hidden'));

    await tester.pumpWidget(
      FlutterLifecycleObserver(
        lifetime: lifetime,
        child: const Placeholder(),
      ),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);

    expect(events, ['hidden']);
  });
}
