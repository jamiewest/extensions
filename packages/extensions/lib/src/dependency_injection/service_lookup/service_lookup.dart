library extensions.dependency_injection.service_lookup;

import 'package:extensions/hosting.dart';
import 'package:extensions/src/dependency_injection/service_lookup/service_provider_call_site.dart';
import 'package:extensions/src/dependency_injection/service_scope_factory.dart';

import '../../common/exceptions/invalid_operation_exception.dart';
import '../service_provider_is_keyed_service.dart';

import 'service_identifier.dart';
import '../service_lifetime.dart';
import 'call_site_result_cache_location.dart';
import 'service_cache_key.dart';
import 'dart:math';

import 'package:collection/collection.dart';
import 'service_descriptor_extensions.dart';

import '../keyed_service_provider.dart';
import '../service_descriptor.dart';
import '../service_provider.dart';
import '../service_provider_factory.dart';
import '../service_provider_is_service.dart';
import 'call_site_chain.dart';
import 'constant_call_site.dart';
import 'factory_call_site.dart';
import 'iterable_call_site.dart';
import 'service_call_site.dart';

import 'throw_helper.dart';
import 'call_site_validator.dart';
import '../../common/async_disposable.dart';
import '../../common/disposable.dart';
import 'runtime_service_provider_engine.dart';
import 'service_provider_engine.dart';

import '../service_provider_options.dart';
import '../service_scope.dart';

import 'call_site_visitor.dart';

part 'result_cache.dart';
part 'call_site_factory.dart';
part '../default_service_provider.dart';
part 'call_site_runtime_resolver.dart';
part 'service_provider_engine_scope.dart';
