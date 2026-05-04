import 'rational_number.dart';

/// Implementations of smoothing functions for BLEU scores taken from `A
/// Systematic Comparison of Smoothing Techniques for Sentence-Level BLEU` by
/// Chen and Cherry. http://acl2014.org/acl2014/W14-33/pdf/W14-3346.pdf.
class SmoothingFunction {
  SmoothingFunction();

  /// This is the baseline method, which does not apply any smoothing.
  ///
  /// Returns: Smoothed precision values.
  ///
  /// [precisions] N precision values to be smoothed.
  ///
  /// [hypLen] Number of tokens in the hypothesis.
  static List<double> method0(List<RationalNumber> precisions, int hypLen) {
    var smoothed = List.filled(precisions.length, null);
    for (var i = 0; i < precisions.length; i++) {
      if (precisions[i].numerator == 0) {
        smoothed[i] = double.epsilon;
      } else {
        smoothed[i] = precisions[i].toDouble();
      }
    }
    return smoothed;
  }

  /// Smoothing method 4: Shorter translations may have inflated precision
  /// values due to having smaller denominators; therefore, we give them
  /// proportionally smaller smoothed counts. Instead of scaling to 1/(2^k),
  /// Chen and Cherry suggests dividing by 1/ln(len(T)), where T is the length
  /// of the translation.
  ///
  /// Returns: Smoothed precision values.
  ///
  /// [precisions] N precision values to be smoothed.
  ///
  /// [hypLen] Number of tokens in the hypothesis.
  static List<double> method4(List<RationalNumber> precisions, int hypLen) {
    var DefaultK = 5.0;
    var smoothed = List.filled(precisions.length, null);
    var inc = 1;
    for (var i = 0; i < precisions.length; i++) {
      var p = precisions[i];
      if (p.numerator == 0 && hypLen > 1) {
        var numerator = 1 / (Math.pow(2.0, inc) * DefaultK / Math.log(hypLen));
        smoothed[i] = numerator / p.denominator;
        inc++;
      } else {
        smoothed[i] = p.toDouble();
      }
    }
    return smoothed;
  }
}
