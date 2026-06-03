import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/pasta_recipe.dart';
import '../models/spaghetti_dish.dart';
import '../services/recipe_service.dart';
import '../services/serialization_service.dart';
import '../theme/app_colors.dart';

class SerializationScreen extends StatefulWidget {
  const SerializationScreen({super.key});

  @override
  State<SerializationScreen> createState() => _SerializationScreenState();
}

class _SerializationScreenState extends State<SerializationScreen> {
  final SerializationService _service = SerializationService();
  final RecipeService _recipeService = RecipeService();

  String _jsonString = '';
  List<PastaRecipe> _deserializedRecipes = [];
  List<PastaRecipe> _parsedRecipes = [];
  bool _isParsing = false;
  String _parseDuration = 'Ready';
  String _parseMode = 'Background isolate';

  void _serializeRecipes(List<SpaghettiDish> recipes) {
    setState(() {
      _jsonString = _service.recipesToPrettyJson(recipes);
      _deserializedRecipes = [];
      _parsedRecipes = [];
      _parseDuration =
          'JSON generated from ${recipes.length} Firestore recipes';
    });
  }

  void _deserializeRecipes() {
    if (_jsonString.isEmpty) return;
    setState(() {
      _deserializedRecipes = _service.parseRecipeJsonMainThread(_jsonString);
      _parsedRecipes = [];
      _parseMode = 'JSON decode';
      _parseDuration =
          '${_deserializedRecipes.length} recipes rebuilt from JSON';
    });
  }

  Future<void> _parseInBackground() async {
    if (_jsonString.isEmpty) return;
    setState(() {
      _isParsing = true;
      _parsedRecipes = [];
      _deserializedRecipes = [];
      _parseMode = 'Background isolate';
      _parseDuration = 'Parsing in the background...';
    });

    final stopwatch = Stopwatch()..start();
    final result = await _service.parseRecipeJsonBackground(_jsonString);
    stopwatch.stop();

    if (!mounted) return;
    setState(() {
      _isParsing = false;
      _parsedRecipes = result;
      _parseDuration = 'Done in ${stopwatch.elapsedMilliseconds} ms';
    });
  }

  Future<void> _parseInMainThread() async {
    if (_jsonString.isEmpty) return;
    setState(() {
      _isParsing = true;
      _parsedRecipes = [];
      _deserializedRecipes = [];
      _parseMode = 'Main thread';
      _parseDuration = 'Parsing on the UI thread...';
    });

    await Future.delayed(const Duration(milliseconds: 80));

    final stopwatch = Stopwatch()..start();
    final result = _service.parseRecipeJsonMainThread(_jsonString);
    stopwatch.stop();

    if (!mounted) return;
    setState(() {
      _isParsing = false;
      _parsedRecipes = result;
      _parseDuration = 'Done in ${stopwatch.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Data Lab')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: StreamBuilder<List<SpaghettiDish>>(
          stream: _recipeService.watchRecipes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to fetch recipes: ${snapshot.error}'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final recipes = snapshot.data!;
            final jsonSize = _jsonString.isEmpty
                ? '0 KB'
                : '${(utf8.encode(_jsonString).length / 1024).toStringAsFixed(1)} KB';
            final previewRecipes = _parsedRecipes.isNotEmpty
                ? _parsedRecipes
                : _deserializedRecipes;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroPanel(
                        recipeCount: recipes.length,
                        jsonSize: jsonSize,
                        parseMode: _parseMode,
                        parseDuration: _parseDuration,
                        isParsing: _isParsing,
                      ),
                      const SizedBox(height: 16),
                      _ActionRail(
                        canUseJson: _jsonString.isNotEmpty,
                        onSerialize: recipes.isEmpty
                            ? null
                            : () => _serializeRecipes(recipes),
                        onDeserialize: _jsonString.isEmpty
                            ? null
                            : _deserializeRecipes,
                        onMainThread: _jsonString.isEmpty || _isParsing
                            ? null
                            : _parseInMainThread,
                        onBackground: _jsonString.isEmpty || _isParsing
                            ? null
                            : _parseInBackground,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 860;
                          final jsonPanel = _JsonPanel(jsonString: _jsonString);
                          final resultPanel = _ResultPanel(
                            recipes: previewRecipes,
                            sourceRecipes: recipes,
                          );
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: jsonPanel),
                                const SizedBox(width: 16),
                                Expanded(flex: 4, child: resultPanel),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              jsonPanel,
                              const SizedBox(height: 16),
                              resultPanel,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _ExplainPanel(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.recipeCount,
    required this.jsonSize,
    required this.parseMode,
    required this.parseDuration,
    required this.isParsing,
  });

  final int recipeCount;
  final String jsonSize;
  final String parseMode;
  final String parseDuration;
  final bool isParsing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.highlightGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.berry.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.butter,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: isParsing
                ? const Padding(
                    padding: EdgeInsets.all(22),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(
                    Icons.data_object,
                    color: AppColors.strawberry,
                    size: 42,
                  ),
          ),
          SizedBox(
            width: 390,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Firestore recipes -> JSON -> Dart objects',
                  style: TextStyle(
                    color: AppColors.berry,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fetch the current recipe collection, serialize it, then compare main-thread parsing with background parsing.',
                  style: TextStyle(
                    color: AppColors.softInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _MetricPill(value: '$recipeCount', label: 'recipes'),
          _MetricPill(value: jsonSize, label: 'JSON size'),
          _MetricPill(value: parseDuration, label: parseMode),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.strawberry,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.softInk,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.canUseJson,
    required this.onSerialize,
    required this.onDeserialize,
    required this.onMainThread,
    required this.onBackground,
  });

  final bool canUseJson;
  final VoidCallback? onSerialize;
  final VoidCallback? onDeserialize;
  final VoidCallback? onMainThread;
  final VoidCallback? onBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.65)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onSerialize,
            icon: const Icon(Icons.cloud_download),
            label: const Text('Fetch to JSON'),
          ),
          OutlinedButton.icon(
            onPressed: onDeserialize,
            icon: const Icon(Icons.restore_page),
            label: const Text('Deserialize'),
          ),
          OutlinedButton.icon(
            onPressed: onMainThread,
            icon: const Icon(Icons.warning_amber),
            label: const Text('Parse on Main'),
          ),
          ElevatedButton.icon(
            onPressed: onBackground,
            icon: const Icon(Icons.bolt),
            label: const Text('Parse in Background'),
          ),
        ],
      ),
    );
  }
}

class _JsonPanel extends StatelessWidget {
  const _JsonPanel({required this.jsonString});

  final String jsonString;

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      icon: Icons.code,
      title: 'Serialized JSON Payload',
      child: Container(
        height: 420,
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2F2430),
          borderRadius: BorderRadius.circular(14),
        ),
        child: SingleChildScrollView(
          child: Text(
            jsonString.isEmpty
                ? 'Tap "Fetch to JSON" to serialize your Firestore recipes.'
                : jsonString,
            style: TextStyle(
              color: jsonString.isEmpty ? AppColors.peach : AppColors.cream,
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.recipes, required this.sourceRecipes});

  final List<PastaRecipe> recipes;
  final List<SpaghettiDish> sourceRecipes;

  @override
  Widget build(BuildContext context) {
    final displayItems = recipes.take(8).toList();
    return _PanelShell(
      icon: Icons.restaurant_menu,
      title: 'Parsed Recipe Objects',
      child: Column(
        children: [
          if (displayItems.isEmpty)
            _SourcePreview(recipes: sourceRecipes)
          else
            ...displayItems.map(
              (recipe) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.butter.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.line.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.ramen_dining,
                        color: AppColors.leaf,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.recipeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.berry,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${recipe.chefName} • ${recipe.cookingTime} min • ${recipe.ingredients.length} ingredients',
                            style: const TextStyle(
                              color: AppColors.softInk,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      recipe.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppColors.strawberry,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SourcePreview extends StatelessWidget {
  const _SourcePreview({required this.recipes});

  final List<SpaghettiDish> recipes;

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No Firestore recipes found yet. Add or seed recipes first.',
        ),
      );
    }

    return Column(
      children: recipes.take(5).map((recipe) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.cloud_done, color: AppColors.mint),
          title: Text(
            recipe.name,
            style: const TextStyle(
              color: AppColors.berry,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text('Ready to serialize • ${recipe.category}'),
        );
      }).toList(),
    );
  }
}

class _ExplainPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates, color: AppColors.leaf),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Serialization turns Firestore recipe objects into JSON for transport or storage. Background parsing uses an isolate so large JSON payloads can be decoded without blocking the interface.',
              style: TextStyle(
                color: AppColors.cocoa,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.berry.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.peach.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.strawberry),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.berry,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
