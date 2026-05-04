import '../../open_telemetry_consts.dart';
import '../usage_details.dart';
import 'ai_content.dart';

/// Represents usage information associated with a chat request and response.
class UsageContent extends AContent {
  /// Initializes a new instance of the [UsageContent] class with the specified
  /// [UsageDetails] instance.
  ///
  /// [details] The usage details to store in this content.
  UsageContent(UsageDetails details)
    : details = details,
      _details = Throw.ifNull(details);

  /// Usage information.
  UsageDetails _details;

  /// Gets or sets the usage information.
  UsageDetails details;

  /// Gets a string representing this instance to display in the debugger.
  String get debuggerDisplay {
    return 'Usage = ${_details.debuggerDisplay}';
  }
}
