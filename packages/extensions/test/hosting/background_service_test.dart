import 'dart:async';

import 'package:extensions/dependency_injection.dart';
import 'package:extensions/hosting.dart';
import 'package:extensions/options.dart';
import 'package:extensions/src/hosting/background_service_exception_behavior.dart';
import 'package:extensions/src/hosting/host_options.dart';
import 'package:extensions/system.dart' hide equals;
import 'package:test/test.dart';

void main() {
  group('BackgroundServiceTests', () {
    test('start returns while execute is still running', () async {
      final service = _GatedService();

      await service.start(CancellationToken.none);

      expect(service.started.isCompleted, isTrue);
      expect(service.executeOperation, isNotNull);
      expect(service.executeOperation!.isCompleted, isFalse);
      expect(service.completed, isFalse);

      service.release.complete();
      await service.executeOperation!.value;
      expect(service.completed, isTrue);
    });

    test('stop does not rethrow execute cancellation', () async {
      final service = _ThrowOnCancelService(OperationCanceledException());

      await service.start(CancellationToken.none);
      await expectLater(service.stop(CancellationToken.none), completes);
    });

    test('stop does not rethrow execute error', () async {
      final service = _ThrowOnCancelService(Exception('execute failed'));

      await service.start(CancellationToken.none);
      await expectLater(service.stop(CancellationToken.none), completes);
    });

    test('dispose before start does not throw', () {
      final service = _GatedService();
      expect(service.dispose, returnsNormally);
    });
  });

  group('HostBackgroundServiceTests', () {
    test('Host.start returns while a background service runs', () async {
      final service = _GatedService();
      final builder = Host.createApplicationBuilder();
      builder.services.addHostedService<_GatedService>((sp) => service);
      final host = builder.build();

      await host.start();

      expect(service.started.isCompleted, isTrue);
      expect(service.executeOperation!.isCompleted, isFalse);

      service.release.complete();
      await service.executeOperation!.value;
      await host.stop();
    });

    test('background service fault triggers stop when behavior is stopHost',
        () async {
      final builder = Host.createApplicationBuilder();
      builder.services
        ..configure<HostOptions>(
          HostOptions.new,
          (o) => o.backgroundServiceExceptionBehavior =
              BackgroundServiceExceptionBehavior.stopHost,
        )
        ..addHostedService<_FaultingService>((sp) => _FaultingService());
      final host = builder.build();

      final lifetime =
          host.services.getRequiredService<HostApplicationLifetime>();
      final stopping = Completer<void>();
      lifetime.applicationStopping.register((_) {
        if (!stopping.isCompleted) {
          stopping.complete();
        }
      });

      await host.start();

      await stopping.future;
      expect(stopping.isCompleted, isTrue);
    });
  });
}

/// A service whose [execute] blocks until [release] completes, signalling
/// [started] once it begins running.
final class _GatedService extends BackgroundService {
  final Completer<void> started = Completer<void>();
  final Completer<void> release = Completer<void>();
  bool completed = false;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    if (!started.isCompleted) {
      started.complete();
    }
    await release.future;
    completed = true;
  }
}

/// A service that completes its work with [error] when the stopping token is
/// triggered.
final class _ThrowOnCancelService extends BackgroundService {
  _ThrowOnCancelService(this.error);

  final Object error;

  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    final completer = Completer<void>();
    stoppingToken.register((_) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });
    await completer.future;
  }
}

/// A service that faults asynchronously after start has returned.
final class _FaultingService extends BackgroundService {
  @override
  Future<void> execute(CancellationToken stoppingToken) async {
    await Future<void>.delayed(Duration.zero);
    throw Exception('background work failed');
  }
}
