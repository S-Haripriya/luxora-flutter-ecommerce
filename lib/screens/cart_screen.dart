import 'package:flutter/material.dart';

import '../data/cart.dart';
import '../data/products.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Product> get cartProducts {
    final result = <Product>[];

    for (final product in products) {
      if (Cart.items.containsKey(product.id)) {
        result.add(product);
      }
    }

    return result;
  }

  double get subtotal {
    double total = 0;

    for (final product in cartProducts) {
      total += product.price *
          Cart.quantity(product);
    }

    return total;
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final productsInCart = cartProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: productsInCart.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add products to get started.',
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        productsInCart.length,
                    separatorBuilder:
                        (_, _) =>
                            const SizedBox(height: 12),
                    itemBuilder:
                        (context, index) {
                      final product =
                          productsInCart[index];

                      final quantity =
                          Cart.quantity(product);

                      return Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(12),
                                child: Image.asset(
                                         product.imageUrl,
                                         width: 80,
                                         height: 80,
                                         fit: BoxFit.cover,
                                         errorBuilder: (
                                           context,
                                           error,
                                           stackTrace,
                                         ) {
                                           return const SizedBox(
                                             width: 80,
                                             height: 80,
                                             child: Icon(
                                               Icons.image_not_supported_outlined,
                                             ),
                                           );
                                         },
                                       )
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(
                                      '₹${product.price.toStringAsFixed(0)}',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Cart.remove(
                                              product,
                                            );
                                            _update();
                                          },
                                          icon:
                                              const Icon(
                                            Icons
                                                .remove_circle_outline,
                                          ),
                                        ),

                                        Text(
                                          '$quantity',
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),

                                        IconButton(
                                          onPressed: () {
                                            Cart.add(
                                              product,
                                            );
                                            _update();
                                          },
                                          icon:
                                              const Icon(
                                            Icons
                                                .add_circle_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black
                            .withValues(alpha: 0.08),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹${subtotal.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger
                                  .of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Checkout flow coming soon.',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'PROCEED TO CHECKOUT',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}