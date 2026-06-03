import 'package:flutter/material.dart';

import '../models/spaghetti_dish.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.iconSize = 48,
  });

  final SpaghettiDish recipe;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (recipe.imageUrl.isNotEmpty) {
      return Image.network(
        recipe.imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }

    if (recipe.imageAsset.isNotEmpty) {
      return Image.asset(
        recipe.imageAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }

    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Icon(Icons.restaurant, size: iconSize, color: Colors.grey),
    );
  }
}
