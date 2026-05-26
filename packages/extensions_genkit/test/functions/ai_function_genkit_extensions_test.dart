import 'package:extensions_genkit/extensions_genkit.dart';
import 'package:genkit/genkit.dart';
import 'package:test/test.dart';

AIFunction _makeFunction({
  String name = 'myFn',
  String description = 'Does something useful.',
  Map<String, dynamic>? schema,
}) =>
    AIFunctionFactory.create(
      name: name,
      description: description,
      parametersSchema: schema,
      callback: (args, {cancellationToken}) async => null,
    );

void main() {
  group('AIFunction.toGenkitToolDefinition', () {
    test('preserves name and description', () {
      final def = _makeFunction(
        name: 'getWeather',
        description: 'Returns the current weather.',
      ).toGenkitToolDefinition();

      expect(def.name, 'getWeather');
      expect(def.description, 'Returns the current weather.');
    });

    test('passes parametersSchema as inputSchema', () {
      final schema = {
        'type': 'object',
        'properties': {
          'location': {'type': 'string'},
        },
        'required': ['location'],
      };
      final def = _makeFunction(schema: schema).toGenkitToolDefinition();

      expect(def.inputSchema, schema);
    });

    test('inputSchema is null when parametersSchema is null', () {
      final def = _makeFunction().toGenkitToolDefinition();
      expect(def.inputSchema, isNull);
    });

    test('falls back to name when description is empty', () {
      final fn = AIFunctionFactory.create(
        name: 'fallback',
        callback: (args, {cancellationToken}) async => null,
      );
      final def = fn.toGenkitToolDefinition();
      expect(def.description, 'fallback');
    });
  });

  group('AIFunction.toGenkitTool', () {
    test('preserves name and description', () {
      final tool = _makeFunction(
        name: 'compute',
        description: 'Computes a value.',
      ).toGenkitTool();

      expect(tool.name, 'compute');
      expect(tool.description, 'Computes a value.');
    });

    test('returns a Tool instance', () {
      final tool = _makeFunction().toGenkitTool();
      expect(tool, isA<Tool>());
    });

    test('tool description falls back to name when AIFunction has none', () {
      final fn = AIFunctionFactory.create(
        name: 'noDesc',
        callback: (args, {cancellationToken}) async => null,
      );
      expect(fn.toGenkitTool().description, 'noDesc');
    });
  });
}
