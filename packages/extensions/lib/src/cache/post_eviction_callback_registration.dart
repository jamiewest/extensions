import 'post_eviction_delegate.dart';

class PostEvictionCallbackRegistration {
  PostEvictionCallbackRegistration({
    required this.evictionCallback,
    required this.state,
  });

  final PostEvictionDelegate evictionCallback;

  final Object? state;
}
