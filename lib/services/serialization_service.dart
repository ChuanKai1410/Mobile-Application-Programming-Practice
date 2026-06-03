import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pasta_recipe.dart';
import '../models/spaghetti_dish.dart';

class SerializationService {
  String recipesToPrettyJson(List<SpaghettiDish> recipes) {
    final payload = recipes.map(_recipeToJson).toList();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  List<PastaRecipe> parseRecipeJsonMainThread(String jsonString) {
    final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
    return parsed
        .map<PastaRecipe>((json) => PastaRecipe.fromJson(json))
        .toList();
  }

  Future<List<PastaRecipe>> parseRecipeJsonBackground(String jsonString) async {
    return compute(_parseJsonIsolate, jsonString);
  }

  // Generates a large JSON string representing many recipes
  String generateLargeJson() {
    final List<Map<String, dynamic>> list = List.generate(5000, (index) {
      return {
        'id': 'recipe_$index',
        'recipeName': 'Pasta Dish $index',
        'ingredients': ['Spaghetti', 'Olive Oil', 'Garlic', 'Salt'],
        'cookingTime': 10 + (index % 20),
        'chefName': 'Chef ${index % 50}',
        'rating': 3.0 + ((index % 20) / 10),
      };
    });

    return jsonEncode(list);
  }

  // Parses JSON in the main thread (causes jank)
  List<PastaRecipe> parseJsonMainThread(String jsonString) {
    final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
    return parsed
        .map<PastaRecipe>((json) => PastaRecipe.fromJson(json))
        .toList();
  }

  // Parses JSON in a background isolate using compute()
  Future<List<PastaRecipe>> parseJsonBackground(String jsonString) async {
    // compute function runs top-level or static function in an isolate
    return await compute(_parseJsonIsolate, jsonString);
  }

  Map<String, dynamic> _recipeToJson(SpaghettiDish recipe) {
    final cookTime = RegExp(r'\d+').firstMatch(recipe.cookTime)?.group(0);
    return {
      'id': recipe.id.isEmpty ? recipe.name : recipe.id,
      'recipeName': recipe.name,
      'ingredients': recipe.ingredients.isEmpty
          ? ['Recipe details not added yet']
          : recipe.ingredients,
      'cookingTime': int.tryParse(cookTime ?? '') ?? 0,
      'chefName': recipe.category,
      'rating': _ratingFromReviews(recipe.reviews),
    };
  }

  double _ratingFromReviews(String reviews) {
    final count = int.tryParse(
      RegExp(r'\d+').firstMatch(reviews)?.group(0) ?? '',
    );
    if (count == null || count == 0) return 4.0;
    return (3.8 + (count % 12) / 10).clamp(3.8, 5.0);
  }
}

// Top level function needed for compute()
List<PastaRecipe> _parseJsonIsolate(String jsonString) {
  final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<PastaRecipe>((json) => PastaRecipe.fromJson(json)).toList();
}
