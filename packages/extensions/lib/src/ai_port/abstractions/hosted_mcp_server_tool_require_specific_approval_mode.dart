import 'hosted_mcp_server_tool_approval_mode.dart';

/// Represents a mode where approval behavior is specified for individual tool
/// names.
class HostedMcpServerToolRequireSpecificApprovalMode extends HostedMcpServerToolApprovalMode {
  /// Initializes a new instance of the
  /// [HostedMcpServerToolRequireSpecificApprovalMode] class that specifies
  /// approval behavior for individual tool names.
  ///
  /// [alwaysRequireApprovalToolNames] The list of tools names that always
  /// require approval.
  ///
  /// [neverRequireApprovalToolNames] The list of tools names that never require
  /// approval.
  const HostedMcpServerToolRequireSpecificApprovalMode(
    List<String>? alwaysRequireApprovalToolNames,
    List<String>? neverRequireApprovalToolNames,
  ) :
      alwaysRequireApprovalToolNames = alwaysRequireApprovalToolNames,
      neverRequireApprovalToolNames = neverRequireApprovalToolNames;

  /// Gets or sets the list of tool names that always require approval.
  List<String>? alwaysRequireApprovalToolNames;

  /// Gets or sets the list of tool names that never require approval.
  List<String>? neverRequireApprovalToolNames;

  @override
  bool equals(Object? obj) {
    return obj is HostedMcpServerToolRequireSpecificApprovalMode other &&
        listEquals(alwaysRequireApprovalToolNames, other.alwaysRequireApprovalToolNames) &&
        listEquals(neverRequireApprovalToolNames, other.neverRequireApprovalToolNames);
  }

  @override
  int getHashCode() {
    return combine(
      getListHashCode(alwaysRequireApprovalToolNames),
      getListHashCode(neverRequireApprovalToolNames),
    );
  }

  static bool listEquals(List<String>? list1, List<String>? list2, ) {
    return referenceEquals(list1, list2) ||
        (list1 != null&& list2 != null && list1.sequenceEqual(list2));
  }

  static int getListHashCode(List<String>? list) {
    if (list == null) {
      return 0;
    }
    var hash = 0;
    for (var i = 0; i < list.count; i++) {
      hash = combine(hash, list[i]?.getHashCode() ?? 0);
    }
    return hash;
  }

  static int combine(int h1, int h2, ) {
    var rol5 = ((uint)h1 << 5) | ((uint)h1 >> 27);
    return ((int)rol5 + h1) ^ h2;
  }
}
