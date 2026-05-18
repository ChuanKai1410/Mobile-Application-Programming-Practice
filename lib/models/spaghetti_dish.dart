class SpaghettiDish {
  SpaghettiDish({
    required this.name,
    required this.imageAsset,
    required this.description,
    required this.reviews,
    required this.prepTime,
    required this.cookTime,
    required this.feeds,
    required this.price,
    this.isFavorite = false,
    this.isVegetarian = false,
  });

  final String name;
  final String imageAsset;
  final String description;
  final String reviews;
  final String prepTime;
  final String cookTime;
  final String feeds;
  final String price;
  bool isFavorite;
  final bool isVegetarian;
}
