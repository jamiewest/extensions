import 'dart:convert';
import 'dart:io';

import 'package:extensions/annotations.dart';

import '../../../chat_completion/chat_message.dart';
import '../../../chat_completion/chat_response.dart';
import '../../../chat_completion/chat_role.dart';
import '../response_cache.dart';

/// A [ResponseCache] that persists [ChatResponse]s as JSON files on disk.
///
/// Each entry consists of two files:
/// - `<hash>.json` — the serialized [ChatResponse]
/// - `<hash>.expiry` — the expiry timestamp (ISO-8601)
@Source(
  name: 'DiskBasedResponseCache.cs',
  namespace: 'Microsoft.Extensions.AI.Evaluation.Reporting.Storage',
  repository: 'dotnet/extensions',
  path:
      'src/Libraries/Microsoft.Extensions.AI.Evaluation.Reporting.Storage/',
)
class DiskBasedResponseCache implements ResponseCache {
  /// Creates a [DiskBasedResponseCache] under [cacheDir].
  ///
  /// [timeToLive] specifies how long entries remain valid; defaults to 14 days.
  DiskBasedResponseCache(
    String cacheDir, {
    Duration timeToLive = const Duration(days: 14),
    DateTime Function()? clock,
  })  : _cacheDir = cacheDir,
        _timeToLive = timeToLive,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final String _cacheDir;
  final Duration _timeToLive;
  final DateTime Function() _clock;

  @override
  Future<ChatResponse?> get(String key) async {
    final (jsonFile, expiryFile) = _filesFor(key);
    if (!jsonFile.existsSync() || !expiryFile.existsSync()) return null;

    final expiryStr = await expiryFile.readAsString();
    final expiry = DateTime.tryParse(expiryStr.trim());
    if (expiry == null || _clock().isAfter(expiry)) {
      await _deleteEntry(jsonFile, expiryFile);
      return null;
    }

    final json =
        jsonDecode(await jsonFile.readAsString()) as Map<String, dynamic>;
    return _responseFromJson(json);
  }

  @override
  Future<void> set(String key, ChatResponse response) async {
    Directory(_cacheDir).createSync(recursive: true);
    final (jsonFile, expiryFile) = _filesFor(key);
    final expiry = _clock().add(_timeToLive);
    await jsonFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(_responseToJson(response)));
    await expiryFile.writeAsString(expiry.toIso8601String());
  }

  @override
  Future<void> remove(String key) async {
    final (jsonFile, expiryFile) = _filesFor(key);
    await _deleteEntry(jsonFile, expiryFile);
  }

  @override
  Future<void> reset() async {
    final dir = Directory(_cacheDir);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<void> deleteExpiredEntries() async {
    final dir = Directory(_cacheDir);
    if (!dir.existsSync()) return;

    final now = _clock();
    final expiryFiles = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.expiry'))
        .toList();

    for (final expiryFile in expiryFiles) {
      final expiryStr = await expiryFile.readAsString();
      final expiry = DateTime.tryParse(expiryStr.trim());
      if (expiry == null || now.isAfter(expiry)) {
        final base = expiryFile.path.replaceFirst('.expiry', '');
        final jsonFile = File('$base.json');
        await _deleteEntry(jsonFile, expiryFile);
      }
    }
  }

  (File, File) _filesFor(String key) {
    final safeKey = Uri.encodeComponent(key);
    final sep = Platform.pathSeparator;
    final base = '$_cacheDir$sep$safeKey';
    return (File('$base.json'), File('$base.expiry'));
  }

  static Future<void> _deleteEntry(File jsonFile, File expiryFile) async {
    if (jsonFile.existsSync()) await jsonFile.delete();
    if (expiryFile.existsSync()) await expiryFile.delete();
  }

  static Map<String, dynamic> _responseToJson(ChatResponse r) => {
        'text': r.text,
        if (r.modelId != null) 'modelId': r.modelId,
        if (r.usage != null)
          'usage': {
            'inputTokenCount': r.usage!.inputTokenCount,
            'outputTokenCount': r.usage!.outputTokenCount,
            'totalTokenCount': r.usage!.totalTokenCount,
          },
      };

  static ChatResponse _responseFromJson(Map<String, dynamic> j) {
    final response = ChatResponse.fromMessage(
      ChatMessage.fromText(ChatRole.assistant, j['text'] as String? ?? ''),
    );
    response.modelId = j['modelId'] as String?;
    return response;
  }
}
