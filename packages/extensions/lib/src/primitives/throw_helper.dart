import '../system/exceptions/argument_exception.dart';
import '../system/exceptions/argument_null_exception.dart';
import '../system/exceptions/argument_out_of_range_exception.dart';
import '../system/exceptions/invalid_operation_exception.dart';

enum ExceptionResource {
  argumentInvalidOffsetLength,
  argumentInvalidOffsetLengthStringSegment,
  capacityCannotChangeAfterWriteStarted,
  capacityNotEnough,
  capacityNotUsedEntirely,
}

enum ExceptionArgument {
  buffer,
  offset,
  length,
  text,
  start,
  count,
  index_,
  value,
  capacity,
  separators,
  comparisonType,
  changeTokens,
  changeTokenProducer,
  changeTokenConsumer,
  array,
}

/// A helper class to throw exceptions in a consistent manner.
class ThrowHelper {
  static void throwArgumentNullException(ExceptionArgument argument) {
    throw ArgumentNullException(paramName: _getArgumentName(argument));
  }

  static void throwArgumentOutOfRangeException(ExceptionArgument argument) {
    throw ArgumentOutOfRangeException(paramName: _getArgumentName(argument));
  }

  static void throwArgumentException(ExceptionArgument argument) {
    throw ArgumentException(paramName: _getArgumentName(argument));
  }

  static void throwInvalidOperationException(ExceptionArgument argument) {
    throw InvalidOperationException();
  }

  static ArgumentNullException getArgumentNullException(
    ExceptionArgument argument,
  ) =>
      ArgumentNullException(paramName: _getArgumentName(argument));

  //static  getArgumentOutOfRangeException(ExceptionArgument argument) {}

  static ArgumentException getArgumentException(ExceptionResource resource) =>
      ArgumentException(message: _getResourceText(resource));

  static String _getResourceText(ExceptionResource resource) {
    switch (resource) {
      case ExceptionResource.argumentInvalidOffsetLength:
        return 'Invalid offset length.';
      case ExceptionResource.argumentInvalidOffsetLengthStringSegment:
        return 'Invalid offset length for string segment.';
      case ExceptionResource.capacityCannotChangeAfterWriteStarted:
        return 'Capacity cannot change after write started.';
      case ExceptionResource.capacityNotEnough:
        return 'Capacity not enough.';
      case ExceptionResource.capacityNotUsedEntirely:
        return 'Capacity not used entirely.';
    }
  }

  static String _getArgumentName(ExceptionArgument argument) =>
      argument.toString().split('.').last;
}
