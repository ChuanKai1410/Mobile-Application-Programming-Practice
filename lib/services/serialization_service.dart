import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/pasta_recipe.dart';

class SerializationService {
  
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
    return parsed.map<PastaRecipe>((json) => PastaRecipe.fromJson(json)).toList();
  }

  // Parses JSON in a background isolate using compute()
  Future<List<PastaRecipe>> parseJsonBackground(String jsonString) async {
    // compute function runs top-level or static function in an isolate
    return await compute(_parseJsonIsolate, jsonString);
  }
}

// Top level function needed for compute()
List<PastaRecipe> _parseJsonIsolate(String jsonString) {
  final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
  return parsed.map<PastaRecipe>((json) => PastaRecipe.fromJson(json)).toList();
}
