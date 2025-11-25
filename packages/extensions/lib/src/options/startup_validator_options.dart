class StartupValidatorOptions {
  // Maps each pair of a) options type and b) options name to a method that
  // forces its evaluation, e.g. [OptionsMonitor<TOptions>.get(name)]
  final Map<(Type, String), void Function()> validators =
      <(Type, String), void Function()>{};
}
