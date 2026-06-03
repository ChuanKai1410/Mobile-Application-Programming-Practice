import 'package:flutter_test/flutter_test.dart';
import 'package:pasta_shop/models/spaghetti_dish.dart';

void main() {
  test('SpaghettiDish stores Firebase recipe fields', () {
    final recipe = SpaghettiDish(
      id: 'recipe-1',
      name: 'Carbonara',
      description: 'Creamy pasta',
      category: 'Creamy',
      reviews: '0 Reviews',
      prepTime: '10 min',
      cookTime: '15 min',
      feeds: '2',
      price: 'RM14.50',
      ingredients: const ['spaghetti', 'egg', 'cheese'],
      method: const ['Boil pasta', 'Mix sauce'],
      imageUrl: 'https://example.com/carbonara.jpg',
      isVegetarian: false,
    );

    expect(recipe.id, 'recipe-1');
    expect(recipe.category, 'Creamy');
    expect(recipe.ingredients, hasLength(3));
    expect(recipe.method, contains('Mix sauce'));
    expect(recipe.imageSource, recipe.imageUrl);
  });
}
