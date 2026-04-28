import 'spaghetti_dish.dart';

class CartItem {
  final SpaghettiDish dish;
  int amount;

  CartItem({
    required this.dish,
    this.amount = 1,
  });
}
