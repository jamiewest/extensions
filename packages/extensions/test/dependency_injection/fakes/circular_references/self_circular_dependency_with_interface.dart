abstract class SelfCircularDependencyWithInterface {}

class SelfCircularDependencyWithInterfaceImpl
    implements SelfCircularDependencyWithInterface {
  const SelfCircularDependencyWithInterfaceImpl(this.self);
  final SelfCircularDependencyWithInterface self;
}
