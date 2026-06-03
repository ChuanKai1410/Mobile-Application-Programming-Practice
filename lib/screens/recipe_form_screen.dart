import 'package:flutter/material.dart';

import '../models/spaghetti_dish.dart';
import '../services/recipe_service.dart';
import '../theme/app_colors.dart';
import '../widgets/recipe_image.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key, this.recipe});

  final SpaghettiDish? recipe;

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = RecipeService();

  late final TextEditingController _nameController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _priceController;
  late final TextEditingController _prepController;
  late final TextEditingController _cookController;
  late final TextEditingController _feedsController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _methodController;

  bool _isVegetarian = false;
  bool _isSaving = false;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _imageUrlController = TextEditingController(text: recipe?.imageUrl ?? '');
    _descriptionController = TextEditingController(
      text: recipe?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: recipe?.category ?? 'Classic',
    );
    _priceController = TextEditingController(
      text: recipe?.price.replaceAll('RM', '') ?? '',
    );
    _prepController = TextEditingController(text: recipe?.prepTime ?? '');
    _cookController = TextEditingController(text: recipe?.cookTime ?? '');
    _feedsController = TextEditingController(text: recipe?.feeds ?? '');
    _ingredientsController = TextEditingController(
      text: recipe?.ingredients.join('\n') ?? '',
    );
    _methodController = TextEditingController(
      text: recipe?.method.join('\n') ?? '',
    );
    _isVegetarian = recipe?.isVegetarian ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _prepController.dispose();
    _cookController.dispose();
    _feedsController.dispose();
    _ingredientsController.dispose();
    _methodController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final priceNumber = double.parse(_priceController.text.trim());
      final recipe = SpaghettiDish(
        id: widget.recipe?.id ?? '',
        name: _nameController.text.trim(),
        imageAsset: widget.recipe?.imageAsset ?? '',
        imageUrl: _imageUrlController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        reviews: widget.recipe?.reviews ?? '0 Reviews',
        prepTime: _prepController.text.trim(),
        cookTime: _cookController.text.trim(),
        feeds: _feedsController.text.trim(),
        price: 'RM${priceNumber.toStringAsFixed(2)}',
        ingredients: _linesFrom(_ingredientsController.text),
        method: _linesFrom(_methodController.text),
        createdBy: widget.recipe?.createdBy ?? '',
        createdAt: widget.recipe?.createdAt,
        updatedAt: widget.recipe?.updatedAt,
        isVegetarian: _isVegetarian,
      );

      if (_isEditing) {
        await _service.updateRecipe(recipe);
      } else {
        await _service.addRecipe(recipe);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Recipe updated.' : 'Recipe added.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save recipe: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  List<String> _linesFrom(String value) {
    return value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _priceValidator(String? value) {
    final requiredError = _required(value);
    if (requiredError != null) return requiredError;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid price';
    return null;
  }

  String? _linesValidator(String? value) {
    if (_linesFrom(value ?? '').isEmpty) return 'Enter at least one line';
    return null;
  }

  String? _imageUrlValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid image URL';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Image URL must start with http or https';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Recipe' : 'Add Recipe')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ImageUrlPanel(
              recipe: widget.recipe,
              controller: _imageUrlController,
              validator: _imageUrlValidator,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Recipe name'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              minLines: 3,
              maxLines: 5,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (RM)',
                prefixText: 'RM ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _priceValidator,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepController,
                    decoration: const InputDecoration(labelText: 'Prep time'),
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cookController,
                    decoration: const InputDecoration(labelText: 'Cook time'),
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _feedsController,
              decoration: const InputDecoration(labelText: 'Servings'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vegetarian'),
              value: _isVegetarian,
              onChanged: (value) => setState(() => _isVegetarian = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredients (one per line)',
              ),
              minLines: 4,
              maxLines: 8,
              validator: _linesValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _methodController,
              decoration: const InputDecoration(
                labelText: 'Method steps (one per line)',
              ),
              minLines: 4,
              maxLines: 8,
              validator: _linesValidator,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveRecipe,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageUrlPanel extends StatelessWidget {
  const _ImageUrlPanel({
    required this.recipe,
    required this.controller,
    required this.validator,
  });

  final SpaghettiDish? recipe;
  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: recipe == null
                      ? Container(
                          color: AppColors.butter,
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.softInk,
                          ),
                        )
                      : RecipeImage(recipe: recipe!, width: 92, height: 92),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Paste an online image URL for this recipe.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/recipe.jpg',
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
            validator: validator,
          ),
        ],
      ),
    );
  }
}
