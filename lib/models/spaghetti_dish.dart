import 'package:cloud_firestore/cloud_firestore.dart';

class SpaghettiDish {
  SpaghettiDish({
    this.id = '',
    required this.name,
    this.imageAsset = '',
    this.imageUrl = '',
    required this.description,
    this.category = 'Classic',
    required this.reviews,
    required this.prepTime,
    required this.cookTime,
    required this.feeds,
    required this.price,
    this.ingredients = const [],
    this.method = const [],
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.isVegetarian = false,
  });

  final String id;
  final String name;
  final String imageAsset;
  final String imageUrl;
  final String description;
  final String category;
  final String reviews;
  final String prepTime;
  final String cookTime;
  final String feeds;
  final String price;
  final List<String> ingredients;
  final List<String> method;
  final String createdBy;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  bool isFavorite;
  final bool isVegetarian;

  factory SpaghettiDish.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SpaghettiDish(
      id: doc.id,
      name: data['name'] as String? ?? '',
      imageAsset: data['imageAsset'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Classic',
      reviews: data['reviews'] as String? ?? '0 Reviews',
      prepTime: data['prepTime'] as String? ?? '',
      cookTime: data['cookTime'] as String? ?? '',
      feeds: data['feeds'] as String? ?? '',
      price: data['price'] as String? ?? '',
      ingredients: List<String>.from(data['ingredients'] as List? ?? const []),
      method: List<String>.from(data['method'] as List? ?? const []),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
      isVegetarian: data['isVegetarian'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore({
    bool includeCreatedAt = false,
    bool useServerTimestamp = true,
  }) {
    return {
      'name': name.trim(),
      'imageAsset': imageAsset,
      'imageUrl': imageUrl,
      'description': description.trim(),
      'category': category.trim(),
      'reviews': reviews.trim().isEmpty ? '0 Reviews' : reviews.trim(),
      'prepTime': prepTime.trim(),
      'cookTime': cookTime.trim(),
      'feeds': feeds.trim(),
      'price': price.trim(),
      'ingredients': ingredients
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      'method': method
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      'createdBy': createdBy,
      'updatedAt': useServerTimestamp
          ? FieldValue.serverTimestamp()
          : updatedAt,
      'isVegetarian': isVegetarian,
      if (includeCreatedAt)
        'createdAt': useServerTimestamp
            ? FieldValue.serverTimestamp()
            : createdAt,
    };
  }

  SpaghettiDish copyWith({
    String? id,
    String? name,
    String? imageAsset,
    String? imageUrl,
    String? description,
    String? category,
    String? reviews,
    String? prepTime,
    String? cookTime,
    String? feeds,
    String? price,
    List<String>? ingredients,
    List<String>? method,
    String? createdBy,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool? isFavorite,
    bool? isVegetarian,
  }) {
    return SpaghettiDish(
      id: id ?? this.id,
      name: name ?? this.name,
      imageAsset: imageAsset ?? this.imageAsset,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      reviews: reviews ?? this.reviews,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      feeds: feeds ?? this.feeds,
      price: price ?? this.price,
      ingredients: ingredients ?? this.ingredients,
      method: method ?? this.method,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isVegetarian: isVegetarian ?? this.isVegetarian,
    );
  }

  String get imageSource => imageUrl.isNotEmpty ? imageUrl : imageAsset;
}
