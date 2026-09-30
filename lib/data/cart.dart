import '../models/product.dart';

class Cart {
  static final Map<int, int> items = {};

  static void add(Product product) {
    items[product.id] =
        (items[product.id] ?? 0) + 1;
  }

  static void remove(Product product) {
    if (!items.containsKey(product.id)) {
      return;
    }

    if (items[product.id]! > 1) {
      items[product.id] =
          items[product.id]! - 1;
    } else {
      items.remove(product.id);
    }
  }

  static int quantity(Product product) {
    return items[product.id] ?? 0;
  }

  static void clear() {
    items.clear();
  }
}