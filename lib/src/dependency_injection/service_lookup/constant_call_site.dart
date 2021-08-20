import 'call_site_kind.dart';
import 'result_cache.dart';
import 'service_call_site.dart';

class ConstantCallSite extends ServiceCallSite {
  final Type _serviceType;
  final Object? _defaultValue;

  ConstantCallSite(
    Type serviceType,
    Object? defaultValue,
  )   : _serviceType = serviceType,
        _defaultValue = defaultValue,
        super(ResultCache.none);

  Object? get defaultValue => _defaultValue;

  @override
  Type get serviceType => defaultValue?.runtimeType ?? _serviceType;

  @override
  Type get implementationType => defaultValue?.runtimeType ?? _serviceType;

  @override
  CallSiteKind get kind => CallSiteKind.constant;
}
