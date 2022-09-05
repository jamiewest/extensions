enum FlutterEnvironments {
  debug('Debug'),
  profile('Profile'),
  release('Release');

  const FlutterEnvironments(this.name);
  final String name;
}
