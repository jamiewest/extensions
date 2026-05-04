/// Tokenizes text using rules inspired by the NLTK word tokenizer.
///
/// Applies the same normalization steps as the .NET implementation: stripping
/// skip markers, replacing HTML entities, inserting spaces around punctuation,
/// and splitting on whitespace.
class SimpleWordTokenizer {
  static final _htmlEntities = {
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
  };

  // Punctuation / symbols that should become separate tokens.
  static final _punctuationPattern = RegExp(
    r'([\p{P}\p{S}])',
    unicode: true,
  );

  /// Tokenizes [text] into a list of lower-cased word tokens.
  static List<String> wordTokenize(String text) {
    var t = text;

    // Remove BLEU skip markers.
    t = t.replaceAll(RegExp(r'SKIP\d*'), '');

    // Normalize line breaks.
    t = t.replaceAll('\r\n', ' ').replaceAll('\r', ' ').replaceAll('\n', ' ');

    // Decode HTML entities.
    for (final entry in _htmlEntities.entries) {
      t = t.replaceAll(entry.key, entry.value);
    }

    // Lowercase.
    t = t.toLowerCase();

    // Insert spaces around all punctuation / symbol characters.
    t = t.replaceAllMapped(_punctuationPattern, (m) => ' ${m[1]} ');

    // Split on whitespace and remove empty tokens.
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }
}
