/// Annotation used for tracking source information.
class Source {
  const Source({
    required this.name,
    required this.namespace,
    required this.repository,
    required this.path,
    this.alias,
    this.commit,
    this.notes,
  });

  final String name;

  final String? alias;

  final String namespace;

  final String repository;

  final String path;

  final String? commit;

  final String? notes;
}
