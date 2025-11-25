class StartupValidatorOptions {
  // Maps each pair of a) options type and b) options name to a method that
  // forces its evaluation, e.g. [OptionsMonitor<TOptions>.get(name)]
  Map<(Type, String), Function> get validators => {};
}
