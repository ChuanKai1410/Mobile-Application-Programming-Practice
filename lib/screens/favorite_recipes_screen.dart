import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../aglio_olio.dart';
import '../spicy.dart';
import '../creamy_garlic.dart';
import '../tomato.dart';
import '../models/spaghetti_dish.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SpaghettiShopAppState>();
    final favoriteRecipes = appState.favoriteRecipes;

    void openDetail(SpaghettiDish dish) {
      context.read<SpaghettiShopAppState>().selectDish(dish);
      
      Widget detailScreen;
      if (dish.name.contains('Aglio e Olio')) {
        detailScreen = const AglioOlioScreen();
      } else if (dish.name.contains('Arrabbiata')) {
        detailScreen = const SpicyScreen();
      } else if (dish.name.contains('Creamy')) {
        detailScreen = const CreamyGarlicScreen();
      } else {
        detailScreen = const TomatoScreen();
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => detailScreen),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
              child: Text(
                'No favorite recipes yet.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            )
          : ListView.builder(
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
                      child: Image.asset(
                        dish.imageAsset,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      dish.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        appState.toggleFavorite(dish);
                      },
                    ),
                    onTap: () => openDetail(dish),
                  ),
                );
              },
            ),
    );
  }
}
