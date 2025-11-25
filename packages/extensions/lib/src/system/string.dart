bool isNullOrEmpty(String? value) {
  if (value == null || value.isEmpty) return true;
  if (value.isEmpty) return true;
  return false;
}

bool isNullOrWhitespace(String? value) {
  if (value == null) return true;
  return value.trim().isEmpty;
}

bool equals(String value1, String value2, {bool ignoreCase = true}) =>
    ignoreCase
        ? value1.toLowerCase() == value2.toLowerCase()
        : value1 == value2;
