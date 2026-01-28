import 'ai_content.dart';
import 'usage_details.dart';

/// Content representing usage information.
class UsageContent extends AIContent {
  /// Creates a new [UsageContent] with the given [details].
  UsageContent(this.details);

  /// The usage details.
  final UsageDetails details;
}
