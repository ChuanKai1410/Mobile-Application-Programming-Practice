import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:provider/provider.dart';
import 'models/spaghetti_dish.dart';
import 'aglio_olio.dart';
import 'spicy.dart';
import 'creamy_garlic.dart';
import 'tomato.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => SpaghettiShopAppState(),
      child: const MyApp(clientId: ''),
    ),
  );
}

class SpaghettiShopAppState extends ChangeNotifier {
  final List<SpaghettiDish> dishes = const [
    SpaghettiDish(
      name: 'Spaghetti Aglio e Olio',
      imageAsset: 'images/spaghetti_aglio_olio.png',
      description:
          'A classic Italian pasta featuring spaghetti tossed with garlic, red chili, and extra virgin olive oil. Simple yet flavorful, this dish lets the quality of the oil and freshness of ingredients shine through.',
      reviews: '245 Reviews',
      prepTime: '10 min',
      cookTime: '15 min',
      feeds: '2-3',
      price: 'RM12.99',
    ),
    SpaghettiDish(
      name: 'Spicy Spaghetti Arrabbiata',
      imageAsset: 'images/spicy_pasta.png',
      description:
          'A fiery Roman pasta with spaghetti coated in a spicy tomato sauce with garlic and dried red chili. Bold, punchy flavors make this dish perfect for those who love heat.',
      reviews: '189 Reviews',
      prepTime: '8 min',
      cookTime: '18 min',
      feeds: '2',
      price: 'RM11.99',
    ),
    SpaghettiDish(
      name: 'Creamy Garlic Spaghetti',
      imageAsset: 'images/creamy_garlic_pasta.png',
      description:
          'Silky spaghetti coated in a rich garlic cream sauce with fresh parmesan. Luxurious and comforting, perfect for a sophisticated dinner.',
      reviews: '312 Reviews',
      prepTime: '12 min',
      cookTime: '12 min',
      feeds: '2-3',
      price: 'RM13.99',
    ),
    SpaghettiDish(
      name: 'Spaghetti al Pomodoro',
      imageAsset: 'images/tomato_spaghetti.png',
      description:
          'Authentic Italian spaghetti with fresh tomato sauce, basil, and garlic. Light and refreshing with vibrant tomato flavors.',
      reviews: '267 Reviews',
      prepTime: '15 min',
      cookTime: '20 min',
      feeds: '2-3',
      price: 'RM10.99',
    ),
  ];

  SpaghettiDish? _selectedDish;

  SpaghettiDish? get selectedDish => _selectedDish;

  void selectDish(SpaghettiDish dish) {
    _selectedDish = dish;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

    void openDetail(SpaghettiDish dish) {
      context.read<SpaghettiShopAppState>().selectDish(dish);
      
      Widget detailScreen;
      if (dish.name.contains('Aglio e Olio')) {
        detailScreen = const AglioOlioScreen();
      } else if (dish.name.contains('Arrabbiata')) {
        detailScreen = const SpicyScreen();
      } else if (dish.name.contains('Creamy')) {
        detailScreen = const CreamyGarlicScreen();
      } else {
        detailScreen = const TomatoScreen();
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => detailScreen),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍝 Spaghetti Restaurant'),
        backgroundColor: const Color(0xFFD32F2F),
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
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(
                  providers: [EmailAuthProvider()],
                  actions: [
                    SignedOutAction((context) {
                      Navigator.of(context).pop();
                    }),
                  ],
                )),
              );
            },
          ),
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
            final width = constraints.maxWidth;
            final horizontalPadding = width < 600 ? 12.0 : (width < 1100 ? 16.0 : 24.0);
            final crossAxisCount = width < 600
                ? 1
                : width < 900
                    ? 2
                    : width < 1300
                        ? 3
                        : 4;
            final aspectRatio = width < 600 ? 1.25 : (width < 900 ? 0.9 : 0.82);

            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Our Delicious Menu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width < 600 ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD32F2F),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: appState.dishes.length,
                    itemBuilder: (context, index) {
                      final dish = appState.dishes[index];
                      return DishCard(
                        dish: dish,
                        onTap: () => openDetail(dish),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DishCard extends StatelessWidget {
  const DishCard({
    super.key,
    required this.dish,
    required this.onTap,
  });

  final SpaghettiDish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF9C4), Color(0xFFFFE082)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      dish.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.restaurant,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dish.price,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

