import '../models/network_recipe.dart';
import '../models/spaghetti_dish.dart';

class ApiService {
  Future<NetworkResponse> fetchRecipeCatalog(
    List<SpaghettiDish> recipes,
  ) async {
    await _networkDelay();
    return NetworkResponse(
      method: 'GET',
      path: '/api/recipes',
      statusCode: 200,
      message: 'Fetched ${recipes.length} recipes from the app catalog.',
      recipes: recipes.map(NetworkRecipe.fromDish).toList(),
    );
  }

  Future<NetworkResponse> createRecipePreview() async {
    await _networkDelay();
    final recipe = NetworkRecipe(
      recipeId: 'preview_${DateTime.now().millisecondsSinceEpoch}',
      recipeTitle: 'Sunny Lemon Pasta',
      category: 'Preview',
      price: 'RM15.90',
      ingredientCount: 6,
      vegetarian: true,
    );
    return NetworkResponse(
      method: 'POST',
      path: '/api/recipes',
      statusCode: 201,
      message: 'Preview recipe payload accepted.',
      body: recipe.toJson(),
      recipes: [recipe],
    );
  }

  Future<NetworkResponse> updateRecipePreview(
    NetworkRecipe recipe,
    String newTitle,
  ) async {
    await _networkDelay();
    final updated = NetworkRecipe(
      recipeId: recipe.recipeId,
      recipeTitle: newTitle,
      category: recipe.category,
      price: recipe.price,
      ingredientCount: recipe.ingredientCount,
      vegetarian: recipe.vegetarian,
    );
    return NetworkResponse(
      method: 'PATCH',
      path: '/api/recipes/${recipe.recipeId}',
      statusCode: 200,
      message: 'Preview update response generated.',
      body: {'title': newTitle},
      recipes: [updated],
    );
  }

  Future<NetworkResponse> deleteRecipePreview(NetworkRecipe recipe) async {
    await _networkDelay();
    return NetworkResponse(
      method: 'DELETE',
      path: '/api/recipes/${recipe.recipeId}',
      statusCode: 204,
      message: 'Preview delete request completed.',
      body: {'deletedId': recipe.recipeId},
    );
  }

  Future<void> _networkDelay() {
    return Future.delayed(const Duration(milliseconds: 450));
  }
}
