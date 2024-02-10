import 'package:extensions/hosting.dart';
import 'package:extensions/src/common/exceptions/invalid_operation_exception.dart';
import 'package:test/test.dart';

import 'fakes/circular_references/self_circular_dependency.dart';

void main() {
  group('CircularDependencyTests', () {
    test('SelfCircularDependency', () {
      var expectedMessage =
          'A circular dependency was detected for the service of type ' +
              '\'SelfCircularDependency\'.' +
              '\n' +
              'SelfCircularDependency -> ' +
              'SelfCircularDependency';

      var collection = ServiceCollection()
        ..addTransient<SelfCircularDependency>(
          (services) => SelfCircularDependency(
            services.getRequiredService<SelfCircularDependency>(),
          ),
        );

      var serviceProvider = collection.buildServiceProvider();

      expect(
        () => serviceProvider.getRequiredService<SelfCircularDependency>(),
        throwsA(
          predicate(
            (e) =>
                e is InvalidOperationException && e.message == expectedMessage,
          ),
        ),
      );
    });
  });
}
