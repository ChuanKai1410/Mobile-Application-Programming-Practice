import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'models/dish_details.dart';
import 'widgets/dish_detail_content.dart';

class TomatoScreen extends StatelessWidget {
  const TomatoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dish = context.watch<SpaghettiShopAppState>().selectedDish;
    if (dish == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spaghetti al Pomodoro'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: Text('No dish selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spaghetti al Pomodoro'),
        backgroundColor: const Color(0xFFD32F2F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
        ),
        child: DishDetailContent(
          dish: dish,
          ingredients: tomatoDetails.ingredients,
          method: tomatoDetails.method,
        ),
      ),
    );
  }
}
