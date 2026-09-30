import 'package:flutter/material.dart';

import '../data/cart.dart';
import '../models/product.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  void _addToCart(BuildContext context) {
    // Add product to cart.
    Cart.add(product);

    // Get the current ScaffoldMessenger.
    final messenger = ScaffoldMessenger.of(context);

    // Remove any existing SnackBar first.
    messenger.hideCurrentSnackBar();

    // Show confirmation.
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'Product added to cart',
        ),
        duration: const Duration(
          seconds: 3,
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            // Close the SnackBar.
            messenger.hideCurrentSnackBar();

            // Open Cart screen.
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
        ),
        actions: [
          IconButton(
            tooltip: 'Cart',
            onPressed: () {
              _openCart(context);
            },
            icon: const Icon(
              Icons.shopping_bag_outlined,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // PRODUCT IMAGE
            // --------------------------------------------------

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Center(
                      child: Icon(
                        Icons
                            .image_not_supported_outlined,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // CATEGORY
            // --------------------------------------------------

            Text(
              product.category.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // --------------------------------------------------
            // PRODUCT NAME
            // --------------------------------------------------

            Text(
              product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // RATING
            // --------------------------------------------------

            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${product.rating} / 5',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // --------------------------------------------------
            // PRICE
            // --------------------------------------------------

            Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // DESCRIPTION
            // --------------------------------------------------

            Text(
              product.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color:
                    Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 30),

            // --------------------------------------------------
            // ADD TO CART
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 56,
              child:
                  ElevatedButton.icon(
                onPressed: () {
                  _addToCart(context);
                },
                icon: const Icon(
                  Icons
                      .shopping_bag_outlined,
                ),
                label: const Text(
                  'ADD TO CART',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // VIEW CART BUTTON
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 50,
              child:
                  OutlinedButton.icon(
                onPressed: () {
                  _openCart(context);
                },
                icon: const Icon(
                  Icons
                      .shopping_cart_outlined,
                ),
                label: const Text(
                  'VIEW CART',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}