import 'n_gram.dart';

extension NGramExtensions on ReadOnlySpan<T> {NGram<T> createNGram<T>() {
return new(values);
 }
List<NGram<T>> createNGrams<T>({List<T>? input}) {
return createNGrams((ReadOnlySpan<T>)input, n);
 }
List<NGram<T>> createAllNGrams<T>(int maxN, {List<T>? input, }) {
return createAllNGrams((ReadOnlySpan<T>)input, minN, maxN);
 }
 }
