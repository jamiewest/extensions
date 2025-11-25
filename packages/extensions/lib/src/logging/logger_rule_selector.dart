import 'log_level.dart';
import 'logger_filter_options.dart';
import 'logger_filter_rule.dart';
import 'logger_information.dart';

// ignore: avoid_classes_with_only_static_members
class LoggerRuleSelector {
  static (LogLevel?, MessageLoggerFilter?) select(
    LoggerFilterOptions options,
    Type providerType,
    String category,
  ) {
    MessageLoggerFilter? filter;
    var minLevel = options.minLevel;

    // Filter rule selection:
    // 1. Select rules for current logger type, if there is none, select ones
    //    without logger type specified
    // 2. Select rules with longest matching categories
    // 3. If there nothing matched by category take all rules without category
    // 3. If there is only one rule use it's level and filter
    // 4. If there are multiple rules use last
    // 5. If there are no applicable rules use global minimal level

    var providerAlias = providerType.toString();
    LoggerFilterRule? current;
    for (var rule in options.rules) {
      if (isBetter(rule, current, providerAlias, category) ||
          (providerAlias.isNotEmpty &&
              isBetter(rule, current, providerAlias, category))) {
        current = rule;
      }
    }

    if (current != null) {
      filter = current.filter;
      minLevel = current.logLevel;
    }

    return (minLevel, filter);
  }

  static bool isBetter(
    LoggerFilterRule rule,
    LoggerFilterRule? current,
    String logger,
    String category,
  ) {
    // Skip rules with inapplicable type or category
    if (rule.providerName != null && rule.providerName != logger) {
      return false;
    }

    var categoryName = rule.categoryName;
    if (categoryName != null) {
      const wildcardChar = '*';
      var wildcardIndex = categoryName.indexOf(wildcardChar);
      if (wildcardIndex != -1 &&
          categoryName.contains(wildcardChar, wildcardIndex + 1)) {
        throw Exception(
          'Only one wildcard character is allowed in category name.',
        );
      }

      String prefix;
      String suffix;

      if (wildcardIndex == -1) {
        prefix = categoryName;
        suffix = '';
      } else {
        prefix = categoryName.substring(0, wildcardIndex);
        suffix = categoryName.substring(wildcardIndex + 1);
      }

      if (!category.startsWith(prefix) || !category.endsWith(suffix)) {
        return false;
      }
    }

    if (current?.providerName != null) {
      if (rule.providerName == null) {
        return false;
      }
    } else {
      // We want to skip category check when going from no provider to
      // having provider
      if (rule.providerName != null) {
        return true;
      }
    }

    if (current?.categoryName != null) {
      if (rule.categoryName == null) {
        return false;
      }

      if (current!.categoryName!.length > rule.categoryName!.length) {
        return false;
      }
    }

    return true;
  }
}
