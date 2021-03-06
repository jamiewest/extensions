import 'package:extensions/dependency_injection.dart';
import 'package:extensions/logging.dart';
import 'package:uuid/uuid.dart';

void main(List<String> args) {
  var services = ServiceCollection()
    ..addLogging((b) {
      b.addDebug();
    })
    ..tryAddTransient<TransientOperation>((services) => DefaultOperation())
    ..tryAddScoped<ScopedOperation>((services) => DefaultOperation())
    ..tryAddSingleton<SingletonOperation>(
        null, (services) => DefaultOperation())
    ..tryAddTransient<OperationLogger>(
      (services) => OperationLogger(
          services.getService<TransientOperation>(),
          services.getService<ScopedOperation>(),
          services.getService<SingletonOperation>()),
    );

  var sp = services.buildServiceProvider();

  var loggerFactory = sp.getService<LoggerFactory>();
  var logger = loggerFactory.createLogger('test');
  logger.log<String>(
      logLevel: LogLevel.information,
      eventId: EventId(1, 'test'),
      state: 'test',
      formatter: (s, d) => s as String);

  exemplifyScoping(sp, 'Scope 1');
  exemplifyScoping(sp, 'Scope 2');
}

void exemplifyScoping(ServiceProvider services, String scope) {
  var serviceScope = services.createScope();
  var provider = serviceScope.serviceProvider
    ..getRequiredService<OperationLogger>()
        .logOperations('$scope-Call 1 .GetRequiredService<OperationLogger>()');
  print('...');
  provider
      .getRequiredService<OperationLogger>()
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
        // ignore: lines_longer_than_80_chars
        '$scope: ${T.runtimeType.toString()} [ ${operation.operationId}...$message ');
  }
}
