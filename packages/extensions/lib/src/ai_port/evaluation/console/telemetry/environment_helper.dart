class EnvironmentHelper {
  EnvironmentHelper();

  static final List<String> _mustBeTrueCIVariables;

  static final List<List<String>> _mustNotBeNullCIVariables;

  static bool getEnvironmentVariableAsBoolean(String name) {
    return Environment.getEnvironmentVariable(name)?.toUpperInvariant() switch
        {
            "TRUE" or "1" or "YES" => true,
            (_) => false
        };
  }

  static bool isCIEnvironment() {
    for (final variable in _mustBeTrueCIVariables) {
      bool value;
      if (bool.tryParse(Environment.getEnvironmentVariable(variable)) && value) {
        return true;
      }
    }
    for (final variables in _mustNotBeNullCIVariables) {
      if (Array.trueForAll(variables, (variable) => !string.isNullOrWhiteSpace(Environment.getEnvironmentVariable(variable)))) {
        return true;
      }
    }
    return false;
  }
}
