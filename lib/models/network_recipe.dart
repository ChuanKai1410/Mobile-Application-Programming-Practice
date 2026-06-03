import 'dart:convert';

import 'spaghetti_dish.dart';

class NetworkRecipe {
  final String recipeId;
  final String recipeTitle;
  final String category;
  final String price;
  final int ingredientCount;
  final bool vegetarian;

  NetworkRecipe({
    required this.recipeId,
    required this.recipeTitle,
    required this.category,
    required this.price,
    required this.ingredientCount,
    required this.vegetarian,
  });

  factory NetworkRecipe.fromDish(SpaghettiDish dish) {
    return NetworkRecipe(
      recipeId: dish.id.isEmpty ? dish.name : dish.id,
      recipeTitle: dish.name,
      category: dish.category,
      price: dish.price,
      ingredientCount: dish.ingredients.length,
      vegetarian: dish.isVegetarian,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': recipeId,
      'title': recipeTitle,
      'category': category,
      'price': price,
      'ingredientCount': ingredientCount,
      'vegetarian': vegetarian,
    };
  }
}

class NetworkResponse {
  final String method;
  final String path;
  final int statusCode;
  final String message;
  final List<NetworkRecipe> recipes;
  final Map<String, dynamic>? body;
  final DateTime timestamp;

  NetworkResponse({
    required this.method,
    required this.path,
    required this.statusCode,
    required this.message,
    this.recipes = const [],
    this.body,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get prettyJson {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'method': method,
      'path': path,
      'statusCode': statusCode,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (body != null) 'requestBody': body,
      'data': recipes.map((recipe) => recipe.toJson()).toList(),
    });
  }
}
