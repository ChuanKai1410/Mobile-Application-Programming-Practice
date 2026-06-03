import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../services/recipe_service.dart';
import '../theme/app_colors.dart';
import '../widgets/recipe_image.dart';
import '../models/spaghetti_dish.dart';
import 'recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SpaghettiShopAppState>();

    void openDetail(SpaghettiDish dish) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: dish)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Recipes')),
      body: StreamBuilder<List<SpaghettiDish>>(
        stream: RecipeService().watchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load favorites: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteRecipes = appState.favoriteRecipesFrom(snapshot.data!);
          if (favoriteRecipes.isEmpty) {
            return const Center(
              child: Text(
                'No favorite recipes yet.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              final dish = favoriteRecipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RecipeImage(recipe: dish, width: 60, height: 60),
                  ),
                  title: Text(
                    dish.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(dish.category),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: AppColors.berry),
                    onPressed: () => appState.toggleFavorite(dish),
                  ),
                  onTap: () => openDetail(dish),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
