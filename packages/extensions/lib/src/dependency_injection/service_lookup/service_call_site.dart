import '../../system/disposable.dart';
import 'call_site_kind.dart';
import 'service_lookup.dart';

/// Summary description for ServiceCallSite
abstract class ServiceCallSite {
  final ResultCache _cache;

  ServiceCallSite(ResultCache cache) : _cache = cache;

  Type get serviceType;
  Type? get implementationType;
  CallSiteKind get kind;
  ResultCache get cache => _cache;
  Object? value;
  Object? key;

  bool captureDisposable() =>
      implementationType == null || implementationType is Disposable;
}
