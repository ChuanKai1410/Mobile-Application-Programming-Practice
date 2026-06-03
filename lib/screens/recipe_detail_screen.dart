import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/spaghetti_dish.dart';
import '../services/recipe_service.dart';
import '../widgets/cart_widget.dart';
import '../widgets/dish_widgets.dart';
import '../widgets/recipe_image.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final SpaghettiDish recipe;

  Future<void> _deleteRecipe(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('Remove "${recipe.name}" from Firestore?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await RecipeService().deleteRecipe(recipe);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Recipe deleted.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete recipe: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeFormScreen(recipe: recipe),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteRecipe(context),
          ),
          const CartBadgeWidget(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final imagePanel = _ImagePanel(recipe: recipe);
            final detailPanel = _DetailPanel(recipe: recipe);

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: imagePanel,
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: detailPanel,
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(14),
              children: [
                SizedBox(height: 240, child: imagePanel),
                const SizedBox(height: 14),
                detailPanel,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ImagePanel extends StatelessWidget {
  const _ImagePanel({required this.recipe});

  final SpaghettiDish recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: RecipeImage(recipe: recipe)),
          Positioned(
            top: 12,
            right: 12,
            child: Consumer<SpaghettiShopAppState>(
              builder: (context, appState, child) {
                final isFav = appState.isFavorite(recipe);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    color: isFav ? Colors.red : Colors.grey[700],
                    onPressed: () => appState.toggleFavorite(recipe),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.recipe});

  final SpaghettiDish recipe;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              recipe.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Chip(
                label: Text(recipe.category),
                backgroundColor: const Color(0xFFFFF3E0),
              ),
            ),
            const SizedBox(height: 12),
            boxedSection(
              Text(
                recipe.description,
                textAlign: TextAlign.center,
                style: descTextStyle,
              ),
            ),
            ratings(recipe),
            iconList(recipe),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<SpaghettiShopAppState>().addToCart(recipe);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${recipe.name} added to cart.')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add to Cart'),
            ),
            const SizedBox(height: 20),
            _TextListSection(
              title: 'Ingredients',
              items: recipe.ingredients,
              numbered: false,
            ),
            const SizedBox(height: 16),
            _TextListSection(
              title: 'Method',
              items: recipe.method,
              numbered: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextListSection extends StatelessWidget {
  const _TextListSection({
    required this.title,
    required this.items,
    required this.numbered,
  });

  final String title;
  final List<String> items;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(items.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: numbered
                      ? Text(
                          '${index + 1}.',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : const Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFFD32F2F),
                        ),
                ),
                Expanded(
                  child: Text(
                    items[index],
                    style: const TextStyle(height: 1.35),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
