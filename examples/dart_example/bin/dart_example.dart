import 'package:extensions/hosting.dart';
import 'package:uuid/uuid.dart';

Future<void> main(List<String> arguments) async {
  var services = ServiceCollection()
    ..tryAddTransient<TransientOperation, DefaultOperation>(
        (services) => DefaultOperation())
    ..tryAddScoped<ScopedOperation, DefaultOperation>(
        (services) => DefaultOperation())
    ..tryAddSingleton<SingletonOperation, DefaultOperation>(
        (services) => DefaultOperation())
    ..tryAddTransient<OperationLogger, OperationLogger>(
      (services) => OperationLogger(
        services.getService<TransientOperation>()! as TransientOperation,
        services.getService<ScopedOperation>()! as ScopedOperation,
        services.getService<SingletonOperation>()! as SingletonOperation,
      ),
    );

  var sp = services.buildServiceProvider();

  exemplifyScoping(sp, 'Scope 1');
  exemplifyScoping(sp, 'Scope 2');
}

void exemplifyScoping(ServiceProvider services, String scope) {
  var serviceScope = services.createScope();
  var provider = serviceScope.serviceProvider;
  (provider.getRequiredService<OperationLogger>() as OperationLogger)
      .logOperations('$scope-Call 1 .GetRequiredService<OperationLogger>()');
  print('...');
  (provider.getRequiredService<OperationLogger>() as OperationLogger)
      .logOperations('$scope-Call 2 .GetRequiredService<OperationLogger>()');
  print('---');
}

abstract class Operation {
  const Operation(this.operationId);
  final String operationId;
}

class TransientOperation extends Operation {
  TransientOperation(String operationId) : super(operationId);
}

class ScopedOperation extends Operation {
  ScopedOperation(String operationId) : super(operationId);
}

class SingletonOperation extends Operation {
  SingletonOperation(String operationId) : super(operationId);
}

class DefaultOperation
    implements TransientOperation, ScopedOperation, SingletonOperation {
  final String _operationId;

  DefaultOperation() : _operationId = const Uuid().v4();

  @override
  String get operationId => _operationId;
}

class OperationLogger {
  OperationLogger(
    this.transientOperation,
    this.scopedOperation,
    this.singletonOperation,
  );

  final TransientOperation transientOperation;
  final ScopedOperation scopedOperation;
  final SingletonOperation singletonOperation;

  void logOperations(String scope) {
    logOperation(transientOperation, scope, 'Always different');
    logOperation(scopedOperation, scope, 'Changes only with scope');
    logOperation(singletonOperation, scope, 'Always the same');
  }

  void logOperation<T extends Operation>(
    T operation,
    String scope,
    String message,
  ) {
    print(
        '$scope: ${T.runtimeType.toString()} [ ${operation.operationId}...$message ');
  }
}
