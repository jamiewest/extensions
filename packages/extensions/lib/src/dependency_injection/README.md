The use of generics with method overloading makes it difficult to reproduce the api. Whenever this occurs, the generic method will be the default while the other will be renamed following this convention:

Method overloading
```csharp
public T? GetService<T>(this IServiceProvider provider);
public object? GetService(this IServiceProvider provider, Type serviceType);
```
would become...
```dart
T? getService<T>();
Object? getServiceFromType(Type serviceType);
```