import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/pasta_recipe.dart';
import '../services/serialization_service.dart';

class SerializationScreen extends StatefulWidget {
  const SerializationScreen({super.key});

  @override
  State<SerializationScreen> createState() => _SerializationScreenState();
}

class _SerializationScreenState extends State<SerializationScreen> {
  final SerializationService _service = SerializationService();

  // Single Serialization state
  final PastaRecipe _sampleRecipe = PastaRecipe(
    id: 'r_101',
    recipeName: 'Penne all\'Arrabbiata',
    ingredients: ['Penne', 'Tomato Sauce', 'Chili Flakes', 'Garlic'],
    cookingTime: 15,
    chefName: 'Chef Mario',
    rating: 4.8,
  );

  String _jsonString = '';
  PastaRecipe? _deserializedRecipe;

  // Background Parsing state
  bool _isParsing = false;
  String _parseDuration = '';
  List<PastaRecipe> _parsedRecipes = [];
  String _largeJson = '';

  @override
  void initState() {
    super.initState();
    _largeJson = _service.generateLargeJson();
  }

  void _serialize() {
    setState(() {
      _jsonString = const JsonEncoder.withIndent(
        '  ',
      ).convert(_sampleRecipe.toJson());
    });
  }

  void _deserialize() {
    if (_jsonString.isNotEmpty) {
      setState(() {
        _deserializedRecipe = PastaRecipe.fromJson(jsonDecode(_jsonString));
      });
    }
  }

  Future<void> _parseInBackground() async {
    setState(() {
      _isParsing = true;
      _parsedRecipes = [];
      _parseDuration = 'Parsing...';
    });

    final stopwatch = Stopwatch()..start();

    // Perform parsing in background isolate
    final result = await _service.parseJsonBackground(_largeJson);

    stopwatch.stop();

    setState(() {
      _isParsing = false;
      _parsedRecipes = result;
      _parseDuration = 'Done in ${stopwatch.elapsedMilliseconds} ms';
    });
  }

  Future<void> _parseInMainThread() async {
    setState(() {
      _isParsing = true;
      _parsedRecipes = [];
      _parseDuration = 'Parsing (UI may freeze)...';
    });

    // Giving UI a frame to update the parsing text before freezing it
    await Future.delayed(const Duration(milliseconds: 100));

    final stopwatch = Stopwatch()..start();

    // Perform parsing in main thread
    final result = _service.parseJsonMainThread(_largeJson);

    stopwatch.stop();

    setState(() {
      _isParsing = false;
      _parsedRecipes = result;
      _parseDuration = 'Done in ${stopwatch.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serialization & Isolates')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Part 1: JSON Serialization',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Original Object:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_sampleRecipe.toString()),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _serialize,
                          child: const Text('To JSON'),
                        ),
                        ElevatedButton(
                          onPressed: _deserialize,
                          child: const Text('From JSON'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_jsonString.isNotEmpty) ...[
                      const Text(
                        'Serialized JSON:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey.shade200,
                        child: Text(
                          _jsonString,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_deserializedRecipe != null) ...[
                      const Text(
                        'Deserialized Object:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _deserializedRecipe.toString(),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            const Text(
              'Part 2: Background Parsing (compute)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Parsing a massive JSON file (5000 items) on the Main Thread causes UI lag. '
              'Using compute() runs it in a background isolate, keeping the UI smooth.',
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                  ),
                  onPressed: _isParsing ? null : _parseInMainThread,
                  icon: const Icon(Icons.warning, color: Colors.orange),
                  label: const Text(
                    'Main Thread',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                  ),
                  onPressed: _isParsing ? null : _parseInBackground,
                  icon: const Icon(Icons.speed, color: Colors.green),
                  label: const Text(
                    'Background',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Center(
              child: _isParsing
                  ? const CircularProgressIndicator()
                  : Text(
                      'Duration: $_parseDuration',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),

            const SizedBox(height: 16),
            if (_parsedRecipes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parsed ${_parsedRecipes.length} recipes successfully!',
                    style: const TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ListView.builder(
                      itemCount: 10, // only show first 10
                      itemBuilder: (context, index) {
                        final recipe = _parsedRecipes[index];
                        return ListTile(
                          title: Text(recipe.recipeName),
                          subtitle: Text(recipe.chefName),
                          trailing: Text('${recipe.rating} ⭐'),
                        );
                      },
                    ),
                  ),
                  const Text(
                    'Showing top 10 results...',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
