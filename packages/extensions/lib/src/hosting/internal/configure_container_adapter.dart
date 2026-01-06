import '../host_builder_context.dart';

typedef ConfigureContainerAdapterDelegate<TContainerBuilder> = void Function(
  HostBuilderContext hostContext,
  TContainerBuilder containerBuilder,
);

abstract class ConfigureContainerAdapter {
  void configureContainer(
    HostBuilderContext hostContext,
    Object containerBuilder,
  );
}

class DefaultConfigureContainerAdapter<TContainerBuilder>
    implements ConfigureContainerAdapter {
  final ConfigureContainerAdapterDelegate<TContainerBuilder> _action;

  DefaultConfigureContainerAdapter(
    ConfigureContainerAdapterDelegate<TContainerBuilder> action,
  ) : _action = action;

  @override
  void configureContainer(
    HostBuilderContext hostContext,
    Object containerBuilder,
  ) =>
      _action(
        hostContext,
        containerBuilder as TContainerBuilder,
      );
}
