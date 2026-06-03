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

  Future<void> _deleteRecipe(
    BuildContext context,
    SpaghettiDish currentRecipe,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('Remove "${currentRecipe.name}" from Firestore?'),
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
      await RecipeService().deleteRecipe(currentRecipe);
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
    final detailStream = recipe.id.isEmpty
        ? Stream<SpaghettiDish?>.value(recipe)
        : RecipeService().watchRecipe(recipe.id);

    return StreamBuilder<SpaghettiDish?>(
      stream: detailStream,
      initialData: recipe,
      builder: (context, snapshot) {
        final currentRecipe = snapshot.data;
        if (currentRecipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe deleted')),
            body: const Center(child: Text('This recipe no longer exists.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(currentRecipe.name),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeFormScreen(recipe: currentRecipe),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteRecipe(context, currentRecipe),
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
                final imagePanel = _ImagePanel(recipe: currentRecipe);
                final detailPanel = _DetailPanel(recipe: currentRecipe);

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
      },
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

class _DetailPanel extends StatefulWidget {
  const _DetailPanel({required this.recipe});

  final SpaghettiDish recipe;

  @override
  State<_DetailPanel> createState() => _DetailPanelState();
}

class _DetailPanelState extends State<_DetailPanel> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = _buildSelectedTab();
        final hasBoundedHeight = constraints.hasBoundedHeight;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: hasBoundedHeight
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              _buildTabs(),
              if (hasBoundedHeight)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: content,
                  ),
                )
              else
                Padding(padding: const EdgeInsets.all(16), child: content),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'Dish'),
          _buildTabButton(1, 'Ingredients'),
          _buildTabButton(2, 'Method'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFFD32F2F)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD32F2F) : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTab() {
    if (_selectedTabIndex == 1) return _buildIngredientsTab();
    if (_selectedTabIndex == 2) return _buildMethodTab();
    return _buildDishTab();
  }

  Widget _buildDishTab() {
    final recipe = widget.recipe;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFFF9C4),
      ),
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
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return _TextListSection(
      title: 'Ingredients',
      items: widget.recipe.ingredients,
      numbered: false,
    );
  }

  Widget _buildMethodTab() {
    return _TextListSection(
      title: 'Method',
      items: widget.recipe.method,
      numbered: true,
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
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No information added yet.'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: numbered
                        ? Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
