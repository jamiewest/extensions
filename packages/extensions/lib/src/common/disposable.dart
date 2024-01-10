// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.

/// Provides a mechanism for releasing unmanaged resources.
abstract class Disposable {
  const Disposable();

  /// Performs application-defined tasks associated with freeing, releasing,
  /// or resetting unmanaged resources.
  void dispose();
}
