extension BuiltInMetricUtilities on EvaluationMetric {void markAsBuiltIn() {
metric.addOrUpdateMetadata(name: BuiltInEvalMetadataName, value: bool.trueString);
 }
bool isBuiltIn() {
return metric.metadata?.tryGetValue(BuiltInEvalMetadataName, out string? stringValue) is true &&
        bool.tryParse(stringValue, out bool value) &&
        value;
 }
 }
