import '../host_builder_context.dart';

typedef ConfigureContainerAdapterDelegate<TContainerBuilder> = void Function(
  HostBuilderContext hostContext,
  TContainerBuilder containerBuilder,
);

class ConfigureContainerAdapter<TContainerBuilder> {
  final ConfigureContainerAdapterDelegate<TContainerBuilder> _action;

  ConfigureContainerAdapter(
    ConfigureContainerAdapterDelegate<TContainerBuilder> action,
  ) : _action = action;

  void configureContainer(
    HostBuilderContext hostContext,
    Object containerBuilder,
  ) =>
      _action(
        hostContext,
        containerBuilder as TContainerBuilder,
      );
}
