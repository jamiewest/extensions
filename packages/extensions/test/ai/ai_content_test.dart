import 'package:extensions/ai.dart';
import 'package:test/test.dart';

void main() {
  group('AIContent', () {
    test('annotations defaults to null', () {
      final content = TextContent('hello');

      expect(content.annotations, isNull);
    });

    test('annotations holds provider-returned citations', () {
      final content = TextContent('grounded answer');

      content.annotations = [
        CitationAnnotation(
          title: 'Example source',
          url: Uri.parse('https://example.com/article'),
          snippet: 'supporting excerpt',
          annotatedRegions: const [
            TextSpanAnnotatedRegion(startIndex: 0, endIndex: 8),
          ],
        ),
      ];

      final citation = content.annotations!.single as CitationAnnotation;
      expect(citation.title, 'Example source');
      expect(citation.url, Uri.parse('https://example.com/article'));
      expect(citation.snippet, 'supporting excerpt');
      final region =
          citation.annotatedRegions!.single as TextSpanAnnotatedRegion;
      expect(region.startIndex, 0);
      expect(region.endIndex, 8);
    });
  });
}
