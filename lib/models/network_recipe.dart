class NetworkRecipe {
  final int chefId;
  final int recipeId;
  final String recipeTitle;

  NetworkRecipe({
    required this.chefId,
    required this.recipeId,
    required this.recipeTitle,
  });

  factory NetworkRecipe.fromJson(Map<String, dynamic> json) {
    return NetworkRecipe(
      // Map JSONPlaceholder fields to our Pasta Recipe domain
      chefId: json['userId'] as int,
      recipeId: json['id'] as int,
      recipeTitle: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': chefId,
      'id': recipeId,
      'title': recipeTitle,
    };
  }
}
