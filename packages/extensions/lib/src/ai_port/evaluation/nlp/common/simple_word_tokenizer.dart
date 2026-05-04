/// Tokenizes a string into segments using the common rules established by the
/// NLTK word tokenizer.
class SimpleWordTokenizer {
  SimpleWordTokenizer();

  /// Tokenizes the input text into individual words based on specific rules for
  /// text normalization and segmentation.
  ///
  /// Remarks: This method applies text normalization steps, such as removing
  /// skipped markers, handling line breaks, and replacing common HTML entities.
  /// It also ensures consistent tokenization by inserting spaces around
  /// punctuation, symbols, and certain character patterns. The tokenization
  /// rules are inspired by common BLEU algorithms, such as those used in NLTK,
  /// SacreBLEU, and MOSES.
  ///
  /// Returns: An enumerable collection of strings, where each string represents
  /// a tokenized word. The collection will be empty if the input text contains
  /// no valid tokens.
  ///
  /// [text] The input text to be tokenized. Cannot be `null`.
  static Iterable<String> wordTokenize({String? text}) {
    _ = Throw.ifNull(text, nameof(text));
    return wordTokenize(text.asMemory());
  }
}
