class SelfCircularDependencyGeneric<TDependency> {
  const SelfCircularDependencyGeneric(this.dependency);

  final SelfCircularDependencyGeneric<String>? dependency;
}
