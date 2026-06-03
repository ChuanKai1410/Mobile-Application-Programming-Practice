import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/spaghetti_dish.dart';

class RecipeService {
  RecipeService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

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
    if (recipe.imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(recipe.imageUrl).delete();
      } on FirebaseException {
        // The recipe document is the source of truth; ignore stale/missing image refs.
      }
    }
  }

  Future<String> uploadRecipeImage(XFile image) async {
    final user = _requireUser();
    final extension = image.name.split('.').last.toLowerCase();
    final safeExtension = extension.length <= 5 ? extension : 'jpg';
    final ref = _storage.ref(
      'recipe_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.$safeExtension',
    );
    await ref.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: image.mimeType ?? 'image/$safeExtension'),
    );
    return ref.getDownloadURL();
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
