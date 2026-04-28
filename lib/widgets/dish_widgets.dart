import 'package:flutter/material.dart';
import '../models/spaghetti_dish.dart';

class DishDetailsColumn extends StatelessWidget {
  const DishDetailsColumn({super.key, required this.dish});

  final SpaghettiDish dish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          boxedSection(
            Text(
              dish.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                fontSize: 20,
              ),
            ),
          ),
          boxedSection(
            Text(
              'Price: ${dish.price}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontFamily: 'Roboto',
                fontSize: 18,
              ),
            ),
          ),
          boxedSection(
            Text(
              dish.description,
              textAlign: TextAlign.center,
              style: descTextStyle,
            ),
          ),
          ratings(dish),
          iconList(dish),
        ],
      ),
    );
  }
}

Widget stars() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.star, color: Colors.amber[700]),
      Icon(Icons.star, color: Colors.amber[700]),
      Icon(Icons.star, color: Colors.amber[700]),
      Icon(Icons.star, color: Colors.amber[700]),
      const Icon(Icons.star, color: Colors.grey),
    ],
  );
}

Widget ratings(SpaghettiDish dish) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFD32F2F), width: 2),
      borderRadius: BorderRadius.circular(6),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        stars(),
        Text(
          dish.reviews,
          style: const TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
            letterSpacing: 0.3,
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}

Widget iconList(SpaghettiDish dish) {
  return DefaultTextStyle.merge(
    style: const TextStyle(
      color: Color(0xFFD32F2F),
      fontWeight: FontWeight.w700,
      fontFamily: 'Roboto',
      fontSize: 16,
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD32F2F), width: 2),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;

          final items = [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.kitchen, color: Colors.orange[700], size: 28),
                const Text('PREP:'),
                const SizedBox(height: 4),
                Text(dish.prepTime),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer, color: Colors.orange[700], size: 28),
                const Text('COOK:'),
                const SizedBox(height: 4),
                Text(dish.cookTime),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, color: Colors.orange[700], size: 28),
                const Text('SERVES:'),
                const SizedBox(height: 4),
                Text(dish.feeds),
              ],
            ),
          ];

          if (isNarrow) {
            return Column(
              children: [
                items[0],
                const SizedBox(height: 12),
                items[1],
                const SizedBox(height: 12),
                items[2],
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items,
          );
        },
      ),
    ),
  );
}

const descTextStyle = TextStyle(
  color: Color(0xFF424242),
  fontWeight: FontWeight.w600,
  fontFamily: 'Roboto',
  letterSpacing: 0.2,
  fontSize: 15,
  height: 1.35,
);

Widget boxedSection(Widget child) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFD32F2F), width: 1),
      borderRadius: BorderRadius.circular(4),
      color: Colors.white,
    ),
    child: child,
  );
}
