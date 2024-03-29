/// Common
///
/// To use, import `package:extensions/common.dart`.
/// {@category Common}
library extensions.common;

export 'src/common/exceptions/argument_exception.dart';
export 'src/common/exceptions/argument_null_exception.dart';
export 'src/common/exceptions/operation_cancelled_exception.dart';
export 'src/common/exceptions/system_exception.dart';
export 'src/common/async_disposable.dart';
export 'src/common/cancellation_token_registration.dart';
export 'src/common/cancellation_token_source.dart';
export 'src/common/cancellation_token.dart';
export 'src/common/disposable.dart';
export 'src/common/string.dart';
export 'src/common/enum.dart';

typedef TimerCallback = void Function(Object? state);
