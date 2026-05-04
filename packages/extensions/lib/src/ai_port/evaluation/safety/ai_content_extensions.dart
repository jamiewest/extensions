import '../../abstractions/contents/ai_content.dart';
import '../../abstractions/contents/data_content.dart';
import '../../abstractions/contents/text_content.dart';
import '../../abstractions/contents/uri_content.dart';
import '../../abstractions/contents/usage_content.dart';

extension AContentExtensions on AContent {bool isTextOrUsage() {
return content is TextContent || content is UsageContent;
 }
bool isImageWithSupportedFormat() {
return (content is UriContent uriContent && isSupportedImageFormat(uriContent.mediaType)) ||
        (content is DataContent dataContent && isSupportedImageFormat(dataContent.mediaType));
 }
 }
