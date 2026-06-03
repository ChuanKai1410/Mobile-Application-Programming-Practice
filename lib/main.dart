import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models/spaghetti_dish.dart';
import 'models/dish_details.dart';
import 'models/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, AuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'widgets/cart_widget.dart';
import 'screens/favorite_recipes_screen.dart';
import 'screens/networking_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/recipe_form_screen.dart';
import 'screens/serialization_screen.dart';
import 'services/recipe_service.dart';
import 'theme/app_colors.dart';
import 'widgets/recipe_image.dart';

String get clientId => dotenv.env['GOOGLE_CLIENT_ID']!;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => SpaghettiShopAppState(),
      child: MyApp(clientId: clientId),
    ),
  );
}

class SpaghettiShopAppState extends ChangeNotifier {
  final List<SpaghettiDish> seedRecipes = [
    SpaghettiDish(
      name: 'Spaghetti Aglio e Olio',
      imageAsset: 'images/spaghetti_aglio_olio.png',
      description:
          'A classic Italian pasta featuring spaghetti tossed with garlic, red chili, and extra virgin olive oil. Simple yet flavorful, this dish lets the quality of the oil and freshness of ingredients shine through.',
      category: 'Classic',
      reviews: '245 Reviews',
      prepTime: '10 min',
      cookTime: '15 min',
      feeds: '2-3',
      price: 'RM12.99',
      ingredients: ingredientLines(aglioOlioDetails),
      method: aglioOlioDetails.method,
      isVegetarian: true,
    ),
    SpaghettiDish(
      name: 'Spicy Spaghetti Arrabbiata',
      imageAsset: 'images/spicy_pasta.png',
      description:
          'A fiery Roman pasta with spaghetti coated in a spicy tomato sauce with garlic and dried red chili. Bold, punchy flavors make this dish perfect for those who love heat.',
      category: 'Spicy',
      reviews: '189 Reviews',
      prepTime: '8 min',
      cookTime: '18 min',
      feeds: '2',
      price: 'RM11.99',
      ingredients: ingredientLines(spicyDetails),
      method: spicyDetails.method,
      isVegetarian: true,
    ),
    SpaghettiDish(
      name: 'Creamy Garlic Spaghetti',
      imageAsset: 'images/creamy_garlic_pasta.png',
      description:
          'Silky spaghetti coated in a rich garlic cream sauce with fresh parmesan. Luxurious and comforting, perfect for a sophisticated dinner.',
      category: 'Creamy',
      reviews: '312 Reviews',
      prepTime: '12 min',
      cookTime: '12 min',
      feeds: '2-3',
      price: 'RM13.99',
      ingredients: ingredientLines(creamyGarlicDetails),
      method: creamyGarlicDetails.method,
      isVegetarian: false, // contains chicken broth
    ),
    SpaghettiDish(
      name: 'Spaghetti al Pomodoro',
      imageAsset: 'images/tomato_spaghetti.png',
      description:
          'Authentic Italian spaghetti with fresh tomato sauce, basil, and garlic. Light and refreshing with vibrant tomato flavors.',
      category: 'Tomato',
      reviews: '267 Reviews',
      prepTime: '15 min',
      cookTime: '20 min',
      feeds: '2-3',
      price: 'RM10.99',
      ingredients: ingredientLines(tomatoDetails),
      method: tomatoDetails.method,
      isVegetarian: true,
    ),
  ];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<String> _favoriteRecipeIds = {};

  // Feature 1: Favorites
  void toggleFavorite(SpaghettiDish dish) {
    final key = dish.id.isNotEmpty ? dish.id : dish.name;
    if (_favoriteRecipeIds.contains(key)) {
      _favoriteRecipeIds.remove(key);
    } else {
      _favoriteRecipeIds.add(key);
    }
    notifyListeners();
  }

  bool isFavorite(SpaghettiDish dish) {
    final key = dish.id.isNotEmpty ? dish.id : dish.name;
    return _favoriteRecipeIds.contains(key);
  }

  List<SpaghettiDish> favoriteRecipesFrom(List<SpaghettiDish> recipes) {
    return recipes.where(isFavorite).toList();
  }

  // Feature 2: Serving Size
  int servingSize = 1;

  void incrementServings() {
    servingSize++;
    notifyListeners();
  }

  void decrementServings() {
    if (servingSize > 1) {
      servingSize--;
      notifyListeners();
    }
  }

  // Feature 3: Vegetarian Filter
  bool showVegetarianOnly = false;

  void toggleVegetarianFilter(bool value) {
    showVegetarianOnly = value;
    notifyListeners();
  }

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  List<String> categoriesFor(List<SpaghettiDish> recipes) {
    final categories =
        recipes
            .map((recipe) => recipe.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['All', ...categories];
  }

  List<SpaghettiDish> displayedRecipesFrom(List<SpaghettiDish> recipes) {
    var filtered = recipes;
    if (showVegetarianOnly) {
      filtered = filtered.where((recipe) => recipe.isVegetarian).toList();
    }
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((recipe) => recipe.category == _selectedCategory)
          .toList();
    }
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(query) ||
            recipe.description.toLowerCase().contains(query) ||
            recipe.category.toLowerCase().contains(query);
      }).toList();
    }
    return filtered;
  }

  // Cart State
  final List<CartItem> _cart = [];
  List<CartItem> get cart => _cart;

  void addToCart(SpaghettiDish dish) {
    int index = _cart.indexWhere((item) => item.dish.name == dish.name);
    if (index >= 0) {
      _cart[index].amount++;
    } else {
      _cart.add(CartItem(dish: dish, amount: 1));
    }
    notifyListeners();
  }

  void removeFromCart(SpaghettiDish dish) {
    int index = _cart.indexWhere((item) => item.dish.name == dish.name);
    if (index >= 0) {
      _cart[index].amount--;
      if (_cart[index].amount <= 0) {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  int get totalCartItems {
    return _cart.fold(0, (total, item) => total + item.amount);
  }

  double get totalCartPrice {
    return _cart.fold(0, (total, item) {
      final priceStr = item.dish.price.replaceAll('RM', '');
      final price = double.tryParse(priceStr) ?? 0.0;
      return total + (price * item.amount);
    });
  }

  Future<void> checkoutOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _cart.isEmpty) return;

    final orderData = {
      'userId': user.uid,
      'userEmail': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'totalPrice': totalCartPrice,
      'items': _cart
          .map(
            (item) => {
              'dishName': item.dish.name,
              'amount': item.amount,
              'price': item.dish.price,
            },
          )
          .toList(),
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
    clearCart();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.strawberry,
          primary: AppColors.strawberry,
          secondary: AppColors.mint,
          tertiary: AppColors.coral,
          surface: AppColors.cream,
          onSurface: AppColors.cocoa,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.strawberry,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cream,
          elevation: 3,
          shadowColor: AppColors.berry.withValues(alpha: 0.16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.strawberry,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.berry,
            backgroundColor: AppColors.cream,
            side: const BorderSide(color: AppColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.berry),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cream,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.strawberry, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
      home: AuthGate(clientId: clientId),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SpaghettiShopAppState>();
    final recipeService = RecipeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaghetti Restaurant'),
        backgroundColor: AppColors.strawberry,
        elevation: 8,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code, color: Colors.white),
            tooltip: 'Serialization',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SerializationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud, color: Colors.white),
            tooltip: 'Networking & HTTP',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NetworkingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteRecipesScreen(),
                ),
              );
            },
          ),
          const CartBadgeWidget(),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              final linkedProviders =
                  user?.providerData.map((e) => e.providerId).toList() ?? [];

              final activeProviders = <AuthProvider>[];
              if (linkedProviders.contains('password')) {
                activeProviders.add(EmailAuthProvider());
              }
              if (linkedProviders.contains('google.com')) {
                activeProviders.add(GoogleProvider(clientId: clientId));
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(scaffoldBackgroundColor: Colors.transparent),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.cream, AppColors.peach],
                        ),
                      ),
                      child: ProfileScreen(
                        appBar: AppBar(
                          title: const Text('User Profile'),
                          backgroundColor: AppColors.strawberry,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        providers:
                            const [], // Empty to disable the built-in editable Linked Accounts
                        actions: [
                          SignedOutAction((context) {
                            Navigator.of(context).pop();
                          }),
                        ],
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            'Sign-in methods',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: linkedProviders.map((provider) {
                              if (provider == 'google.com') {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else if (provider == 'password') {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.email,
                                        color: AppColors.strawberry,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 80,
                                color: AppColors.strawberry,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.berry,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Recipe'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, AppColors.peach],
          ),
        ),
        child: StreamBuilder<List<SpaghettiDish>>(
          stream: recipeService.watchRecipes(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load recipes:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final recipes = snapshot.data!;
            final displayedRecipes = appState.displayedRecipesFrom(recipes);
            final categories = appState.categoriesFor(recipes);

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = width < 600
                    ? 12.0
                    : (width < 1100 ? 16.0 : 24.0);
                final crossAxisCount = width < 600
                    ? 1
                    : width < 900
                    ? 2
                    : width < 1300
                    ? 3
                    : 4;
                final aspectRatio = width < 600
                    ? 1.18
                    : (width < 900 ? 0.88 : 0.82);

                return SingleChildScrollView(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Column(
                    children: [
                      _MenuHeader(
                        width: width,
                        recipeCount: displayedRecipes.length,
                        totalCount: recipes.length,
                      ),
                      _RecipeControls(categories: categories),
                      if (recipes.isEmpty)
                        _EmptyFirestoreState(
                          onSeed: () async {
                            try {
                              await recipeService.seedDefaultRecipes(
                                appState.seedRecipes,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Sample recipes added to Firestore.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to seed recipes: $e'),
                                  ),
                                );
                              }
                            }
                          },
                        )
                      else if (displayedRecipes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(36),
                          child: Text(
                            'No recipes match your search or filters.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: aspectRatio,
                              ),
                          itemCount: displayedRecipes.length,
                          itemBuilder: (context, index) {
                            final dish = displayedRecipes[index];
                            return DishCard(
                              dish: dish,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(recipe: dish),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.width,
    required this.recipeCount,
    required this.totalCount,
  });

  final double width;
  final int recipeCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final isCompact = width < 640;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(isCompact ? 16 : 20),
      decoration: BoxDecoration(
        gradient: AppColors.highlightGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.berry.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _headerContent(isCompact),
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _headerContent(isCompact),
                  ),
                ),
                const SizedBox(width: 18),
                Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: AppColors.butter,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.local_dining,
                    size: 58,
                    color: AppColors.strawberry,
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _headerContent(bool isCompact) {
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Fresh picks',
              style: TextStyle(
                color: AppColors.leaf,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome, color: AppColors.coral, size: 18),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        'Pick a pasta mood',
        style: TextStyle(
          fontSize: isCompact ? 26 : 34,
          fontWeight: FontWeight.w900,
          color: AppColors.berry,
          height: 1.05,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Search, filter, and manage your cloud recipe collection.',
        style: TextStyle(
          color: AppColors.softInk,
          fontSize: isCompact ? 14 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _HeaderMetric(value: '$recipeCount', label: 'shown'),
          _HeaderMetric(value: '$totalCount', label: 'total'),
        ],
      ),
    ];
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.strawberry,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.softInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeControls extends StatelessWidget {
  const _RecipeControls({required this.categories});

  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<SpaghettiShopAppState>();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.berry.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final search = TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name, category, or description',
              prefixIcon: Icon(Icons.search, color: AppColors.strawberry),
            ),
            onChanged: appState.updateSearchQuery,
          );

          final categoryChips = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: appState.selectedCategory == category,
                selectedColor: AppColors.peach,
                backgroundColor: AppColors.cream,
                side: const BorderSide(color: AppColors.line),
                labelStyle: TextStyle(
                  color: appState.selectedCategory == category
                      ? AppColors.berry
                      : AppColors.softInk,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => appState.updateCategory(category),
              );
            }).toList(),
          );

          final vegetarianToggle = FilterChip(
            avatar: Icon(
              appState.showVegetarianOnly ? Icons.eco : Icons.eco_outlined,
              color: appState.showVegetarianOnly
                  ? AppColors.leaf
                  : AppColors.softInk,
              size: 18,
            ),
            label: const Text('Vegetarian'),
            selected: appState.showVegetarianOnly,
            selectedColor: AppColors.mint.withValues(alpha: 0.35),
            backgroundColor: AppColors.cream,
            side: const BorderSide(color: AppColors.line),
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            onSelected: appState.toggleVegetarianFilter,
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: search),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      categoryChips,
                      const SizedBox(height: 8),
                      vegetarianToggle,
                    ],
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              search,
              const SizedBox(height: 12),
              categoryChips,
              const SizedBox(height: 8),
              vegetarianToggle,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyFirestoreState extends StatelessWidget {
  const _EmptyFirestoreState({required this.onSeed});

  final Future<void> Function() onSeed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 72, color: AppColors.strawberry),
          const SizedBox(height: 12),
          const Text(
            'No recipes in Firestore yet.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onSeed,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Seed Sample Recipes'),
          ),
        ],
      ),
    );
  }
}

class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, required this.onTap});

  final SpaghettiDish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.cardGradient,
                ),
              ),
            ),
            Positioned.fill(bottom: 92, child: RecipeImage(recipe: dish)),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dish.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.berry,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.leaf.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dish.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.berry.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dish.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.berry,
                          height: 1.12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.strawberry,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> ingredientLines(DishDetails details) {
  return details.ingredients.map((ingredient) {
    if (ingredient.baseQuantity <= 0) return ingredient.name;
    final quantity =
        ingredient.baseQuantity == ingredient.baseQuantity.truncateToDouble()
        ? ingredient.baseQuantity.truncate().toString()
        : ingredient.baseQuantity.toString();
    final unit = ingredient.unit.trim();
    return unit.isEmpty
        ? '$quantity ${ingredient.name}'
        : '$quantity $unit ${ingredient.name}';
  }).toList();
}
