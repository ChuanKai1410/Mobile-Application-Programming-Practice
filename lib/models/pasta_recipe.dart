class PastaRecipe {
  final String id;
  final String recipeName;
  final List<String> ingredients;
  final int cookingTime;
  final String chefName;
  final double rating;

  PastaRecipe({
    required this.id,
    required this.recipeName,
    required this.ingredients,
    required this.cookingTime,
    required this.chefName,
    required this.rating,
  });

  factory PastaRecipe.fromJson(Map<String, dynamic> json) {
    return PastaRecipe(
      id: json['id'] as String,
      recipeName: json['recipeName'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      cookingTime: json['cookingTime'] as int,
      chefName: json['chefName'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipeName': recipeName,
      'ingredients': ingredients,
      'cookingTime': cookingTime,
      'chefName': chefName,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'PastaRecipe(id: $id, recipeName: $recipeName, ingredients: $ingredients, cookingTime: $cookingTime, chefName: $chefName, rating: $rating)';
  }
}
