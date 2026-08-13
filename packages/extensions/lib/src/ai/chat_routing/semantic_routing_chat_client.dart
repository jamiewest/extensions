import 'dart:math';

import 'package:extensions/annotations.dart';

import '../../system/threading/cancellation_token.dart';
import '../chat_completion/chat_client.dart';
import '../chat_completion/chat_message.dart';
import '../chat_completion/chat_role.dart';
import '../embeddings/embedding_generator.dart';
import 'routing_chat_client.dart';
import 'routing_context.dart';

/// Specifies how profile similarity scores are aggregated for each client
/// by a [SemanticRoutingChatClient].
///
/// Flattened from the C# nested enum
/// `SemanticRoutingChatClient.ScoreAggregation`.
enum SemanticRoutingScoreAggregation {
  /// Average the matching profile scores for each client.
  mean,

  /// Sum the matching profile scores for each client.
  sum,
}

/// Routes requests by semantic similarity to app-provided example
/// utterances.
///
/// Profile embeddings are generated lazily and cached. Each request embeds
/// the last user message and selects the client with the highest score
/// after aggregating the cosine similarities of the best-matching profile
/// utterances. The configured default client is selected when no user
/// message is available or when the highest score is below the configured
/// threshold.
///
/// The configured client instances are used as stable routing identities
/// and are distinguished by reference. Per-call options do not participate
/// in that identity. By default this instance owns the clients and
/// embedding generator and disposes them when it is disposed.
///
/// The example-utterance routing approach is inspired by
/// [Aurelio Labs' semantic-router project](https://github.com/aurelio-labs/semantic-router).
///
/// Upstream marks the ChatRouting family `[Experimental]`; the surface
/// may change as upstream stabilizes.
@Source(
  name: 'SemanticRoutingChatClient.cs',
  namespace: 'Microsoft.Extensions.AI',
  repository: 'dotnet/extensions',
  path: 'src/Libraries/Microsoft.Extensions.AI/ChatRouting/',
)
final class SemanticRoutingChatClient extends RoutingChatClient {
  /// Creates a new [SemanticRoutingChatClient].
  ///
  /// [clientProfiles] associates example utterances with each client.
  /// [defaultClient] is selected when no profile satisfies
  /// [scoreThreshold]. [topK] is the number of highest-scoring profile
  /// utterances, across all clients, whose scores are aggregated. When
  /// [_leaveOpen] is `true`, the configured clients and embedding generator
  /// are left open when this instance is disposed.
  ///
  /// Throws [ArgumentError] when [clientProfiles] is empty or contains an
  /// empty utterance list or a blank utterance, when [topK] is not
  /// positive, or when [scoreThreshold] is outside the possible range for
  /// the configured aggregation.
  SemanticRoutingChatClient({
    required this._embeddingGenerator,
    required Map<ChatClient, List<String>> clientProfiles,
    required ChatClient defaultClient,
    double scoreThreshold = 0.3,
    int topK = 1,
    SemanticRoutingScoreAggregation scoreAggregation =
        SemanticRoutingScoreAggregation.mean,
    this._leaveOpen = false,
  })  : _topK = topK,
        _scoreAggregation = scoreAggregation,
        _scoreThreshold = scoreThreshold {
    if (clientProfiles.isEmpty) {
      throw ArgumentError.value(
        clientProfiles,
        'clientProfiles',
        'At least one client profile must be provided.',
      );
    }

    if (topK <= 0) {
      throw ArgumentError.value(topK, 'topK', 'Must be positive.');
    }

    final scoreLimit = scoreAggregation == SemanticRoutingScoreAggregation.sum
        ? topK.toDouble()
        : 1.0;
    if (scoreThreshold.isNaN ||
        scoreThreshold.isInfinite ||
        scoreThreshold < -scoreLimit ||
        scoreThreshold > scoreLimit) {
      throw ArgumentError.value(
        scoreThreshold,
        'scoreThreshold',
        'Must be within the possible score range for the configured '
            'aggregation.',
      );
    }

    final profiles = <_Profile>[];
    final clients = <ChatClient>[defaultClient];
    for (final entry in clientProfiles.entries) {
      final client = entry.key;
      final utterances = entry.value;
      if (utterances.isEmpty) {
        throw ArgumentError.value(
          clientProfiles,
          'clientProfiles',
          'Every profile client must have at least one example utterance.',
        );
      }

      var clientIndex =
          clients.indexWhere((candidate) => identical(candidate, client));
      if (clientIndex < 0) {
        clientIndex = clients.length;
        clients.add(client);
      }

      for (final utterance in utterances) {
        if (utterance.trim().isEmpty) {
          throw ArgumentError.value(
            clientProfiles,
            'clientProfiles',
            'Profile utterances must not be blank.',
          );
        }

        profiles.add(_Profile(clientIndex, utterance));
      }
    }

    _clients = List.unmodifiable(clients);
    _profiles = List.unmodifiable(profiles);
  }

  final EmbeddingGenerator _embeddingGenerator;
  final bool _leaveOpen;
  final SemanticRoutingScoreAggregation _scoreAggregation;
  final double _scoreThreshold;
  final int _topK;

  late final List<ChatClient> _clients;
  late final List<_Profile> _profiles;

  bool _disposed = false;
  List<_EmbeddedProfile>? _index;
  Future<List<_EmbeddedProfile>>? _pendingIndex;

  @override
  Future<ChatClient> selectClient(
    RoutingContext context,
    CancellationToken? cancellationToken,
  ) async {
    ChatMessage? lastUserMessage;
    for (final message in context.messages) {
      if (message.role == ChatRole.user) {
        lastUserMessage = message;
      }
    }

    final query = lastUserMessage?.text;
    if (query == null || query.trim().isEmpty) {
      return _clients[0];
    }

    final index = await _ensureIndex(cancellationToken);
    final generated = await _embeddingGenerator.generateEmbeddings(
      values: [query],
      cancellationToken: cancellationToken,
    );
    if (generated.length != 1) {
      throw StateError(
        'The embedding generator did not return one query embedding.',
      );
    }

    final queryVector = generated[0].vector;
    if (queryVector.length != index[0].vector.length) {
      throw StateError(
        'The query embedding dimension does not match the profile '
        'embedding dimension.',
      );
    }

    if (_topK == 1) {
      var bestClientIndex = -1;
      var bestScore = double.negativeInfinity;
      for (final profile in index) {
        final score = _cosineSimilarity(queryVector, profile.vector);
        if (score > bestScore) {
          bestClientIndex = profile.clientIndex;
          bestScore = score;
        }
      }

      return bestClientIndex >= 0 && bestScore >= _scoreThreshold
          ? _clients[bestClientIndex]
          : _clients[0];
    }

    final matches = <({int profileIndex, double score})>[
      for (var i = 0; i < index.length; i++)
        (
          profileIndex: i,
          score: _cosineSimilarity(queryVector, index[i].vector),
        ),
    ]..sort((left, right) {
        final scoreComparison = right.score.compareTo(left.score);
        return scoreComparison != 0
            ? scoreComparison
            : left.profileIndex.compareTo(right.profileIndex);
      });

    final matchCount = min(_topK, matches.length);
    final scoreSums = List<double>.filled(_clients.length, 0);
    final scoreCounts = List<int>.filled(_clients.length, 0);
    final clientOrder = <int>[];
    for (var i = 0; i < matchCount; i++) {
      final profile = index[matches[i].profileIndex];
      final clientIndex = profile.clientIndex;
      if (scoreCounts[clientIndex] == 0) {
        clientOrder.add(clientIndex);
      }

      scoreSums[clientIndex] += matches[i].score;
      scoreCounts[clientIndex]++;
    }

    var bestAggregatedClientIndex = -1;
    var bestAggregatedScore = double.negativeInfinity;
    for (final clientIndex in clientOrder) {
      final score = _scoreAggregation == SemanticRoutingScoreAggregation.mean
          ? scoreSums[clientIndex] / scoreCounts[clientIndex]
          : scoreSums[clientIndex];
      if (score > bestAggregatedScore) {
        bestAggregatedClientIndex = clientIndex;
        bestAggregatedScore = score;
      }
    }

    return bestAggregatedClientIndex >= 0 &&
            bestAggregatedScore >= _scoreThreshold
        ? _clients[bestAggregatedClientIndex]
        : _clients[0];
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    if (!_leaveOpen) {
      for (final client in _clients) {
        client.dispose();
      }

      _embeddingGenerator.dispose();
    }

    super.dispose();
  }

  Future<List<_EmbeddedProfile>> _ensureIndex(
    CancellationToken? cancellationToken,
  ) {
    final cached = _index;
    if (cached != null) {
      return Future.value(cached);
    }

    // Concurrent requests share one build. A failed build clears the
    // pending future so the next request retries, mirroring the upstream
    // semaphore-guarded double-checked build.
    return _pendingIndex ??= _buildIndex(cancellationToken).then((index) {
      _index = index;
      return index;
    }).whenComplete(() => _pendingIndex = null);
  }

  Future<List<_EmbeddedProfile>> _buildIndex(
    CancellationToken? cancellationToken,
  ) async {
    final embeddings = await _embeddingGenerator.generateEmbeddings(
      values: _profiles.map((profile) => profile.text),
      cancellationToken: cancellationToken,
    );
    if (embeddings.length != _profiles.length) {
      throw StateError(
        'The embedding generator did not return one embedding per profile '
        'utterance.',
      );
    }

    final dimensions = embeddings[0].vector.length;
    if (dimensions == 0) {
      throw StateError('Profile embeddings must not be empty.');
    }

    final index = <_EmbeddedProfile>[];
    for (var i = 0; i < _profiles.length; i++) {
      if (embeddings[i].vector.length != dimensions) {
        throw StateError(
          'All profile embeddings must have the same dimension.',
        );
      }

      index.add(_EmbeddedProfile(
        _profiles[i].clientIndex,
        List.unmodifiable(embeddings[i].vector),
      ));
    }

    return List.unmodifiable(index);
  }

  static double _cosineSimilarity(List<double> x, List<double> y) {
    var dot = 0.0;
    var xMagnitude = 0.0;
    var yMagnitude = 0.0;
    for (var i = 0; i < x.length; i++) {
      dot += x[i] * y[i];
      xMagnitude += x[i] * x[i];
      yMagnitude += y[i] * y[i];
    }

    return dot / (sqrt(xMagnitude) * sqrt(yMagnitude));
  }
}

class _Profile {
  _Profile(this.clientIndex, this.text);

  final int clientIndex;
  final String text;
}

class _EmbeddedProfile {
  _EmbeddedProfile(this.clientIndex, this.vector);

  final int clientIndex;
  final List<double> vector;
}
