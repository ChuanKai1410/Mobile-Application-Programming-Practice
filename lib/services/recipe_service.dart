import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/spaghetti_dish.dart';

class RecipeService {
  RecipeService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _recipes =>
      _firestore.collection('recipes');

  Stream<List<SpaghettiDish>> watchRecipes() {
    return _recipes
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(SpaghettiDish.fromFirestore).toList(),
        );
  }

  Stream<SpaghettiDish?> watchRecipe(String recipeId) {
    return _recipes.doc(recipeId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return SpaghettiDish.fromFirestore(snapshot);
    });
  }

  Future<void> addRecipe(SpaghettiDish recipe) async {
    final user = _requireUser();
    await _recipes.add(
      recipe
          .copyWith(
            createdBy: user.uid,
            reviews: recipe.reviews.isEmpty ? '0 Reviews' : recipe.reviews,
          )
          .toFirestore(includeCreatedAt: true),
    );
  }

  Future<void> updateRecipe(SpaghettiDish recipe) async {
    if (recipe.id.isEmpty) {
      throw ArgumentError('Recipe id is required for updates.');
    }
    _requireUser();
    await _recipes.doc(recipe.id).update(recipe.toFirestore());
  }

  Future<void> deleteRecipe(SpaghettiDish recipe) async {
    if (recipe.id.isEmpty) {
      throw ArgumentError('Recipe id is required for deletion.');
    }
    _requireUser();
    await _recipes.doc(recipe.id).delete();
  }

  Future<void> seedDefaultRecipes(List<SpaghettiDish> recipes) async {
    final user = _requireUser();
    final existing = await _recipes.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    for (final recipe in recipes) {
      final doc = _recipes.doc();
      batch.set(
        doc,
        recipe
            .copyWith(createdBy: user.uid)
            .toFirestore(includeCreatedAt: true),
      );
    }
    await batch.commit();
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('You must sign in before managing recipes.');
    }
    return user;
  }
}
