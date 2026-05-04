/// Provides constants used by various telemetry services.
class OpenTelemetryConsts {
  OpenTelemetryConsts();
}

class Error {
  Error();
}

class File {
  File();
}

class GenAI {
  GenAI();
}

class Client {
  Client();
}

class OperationDuration {
  OperationDuration();

  static final List<double> explicitBucketBoundaries = [
    0.01,
    0.02,
    0.04,
    0.08,
    0.16,
    0.32,
    0.64,
    1.28,
    2.56,
    5.12,
    10.24,
    20.48,
    40.96,
    81.92,
  ];
}

class TimePerOutputChunk {
  TimePerOutputChunk();

  static final List<double> explicitBucketBoundaries =
      OperationDuration.ExplicitBucketBoundaries;
}

class TimeToFirstChunk {
  TimeToFirstChunk();

  static final List<double> explicitBucketBoundaries =
      OperationDuration.ExplicitBucketBoundaries;
}

class TokenUsage {
  TokenUsage();

  static final List<int> explicitBucketBoundaries = [
    1,
    4,
    16,
    64,
    256,
    1_024,
    4_096,
    16_384,
    65_536,
    262_144,
    1_048_576,
    4_194_304,
    16_777_216,
    67_108_864,
  ];
}

class Conversation {
  Conversation();
}

class Embeddings {
  Embeddings();
}

class Dimension {
  Dimension();
}

class Input {
  Input();
}

class Operation {
  Operation();
}

class Output {
  Output();
}

class Provider {
  Provider();
}

/// Custom attributes for realtime sessions. These attributes are NOT part of
/// the OpenTelemetry GenAI semantic conventions (as of v1.41). They are
/// custom extensions to capture realtime session-specific configuration.
class Realtime {
  Realtime();
}

class Request {
  Request();
}

class Response {
  Response();
}

class Token {
  Token();
}

class Tool {
  Tool();
}

class Call {
  Call();
}

class Usage {
  Usage();
}

class Server {
  Server();
}
