import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'All';
  String _selectedSort = 'Default';

  int _visibleCount = 6;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  void _handleSearch() {
    setState(() {
      _visibleCount = 6;
    });
  }

  // ------------------------------------------------------------
  // INFINITE SCROLL
  // ------------------------------------------------------------

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 400) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final filtered = _filteredProducts;

    if (_isLoadingMore ||
        _visibleCount >= filtered.length) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    // Small delay to visibly demonstrate lazy loading.
    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _visibleCount += 2;

      if (_visibleCount > filtered.length) {
        _visibleCount = filtered.length;
      }

      _isLoadingMore = false;
    });
  }

  // ------------------------------------------------------------
  // FILTERING
  // ------------------------------------------------------------

  List<String> get _categories {
    final categories = <String>{'All'};

    for (final product in products) {
      categories.add(product.category);
    }

    return categories.toList();
  }

  List<Product> get _filteredProducts {
    List<Product> result = List<Product>.from(products);

    // Search
    final query =
        _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      result = result.where((product) {
        return product.name
                .toLowerCase()
                .contains(query) ||
            product.category
                .toLowerCase()
                .contains(query);
      }).toList();
    }

    // Category
    if (_selectedCategory != 'All') {
      result = result
          .where(
            (product) =>
                product.category ==
                _selectedCategory,
          )
          .toList();
    }

    // Sorting
    switch (_selectedSort) {
      case 'Price: Low to High':
        result.sort(
          (a, b) => a.price.compareTo(b.price),
        );
        break;

      case 'Price: High to Low':
        result.sort(
          (a, b) => b.price.compareTo(a.price),
        );
        break;

      case 'Rating':
        result.sort(
          (a, b) => b.rating.compareTo(a.rating),
        );
        break;

      default:
        break;
    }

    return result;
  }

  // ------------------------------------------------------------
  // RESET VISIBLE COUNT
  // ------------------------------------------------------------

  void _resetVisibleProducts() {
    setState(() {
      _visibleCount = 6;
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration:
            const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // ------------------------------------------------------------
  // SORT
  // ------------------------------------------------------------

  void _showSortOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _sortOption('Default'),
                _sortOption('Price: Low to High'),
                _sortOption('Price: High to Low'),
                _sortOption('Rating'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortOption(String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(value),
      trailing: _selectedSort == value
          ? const Icon(Icons.check)
          : null,
      onTap: () {
        setState(() {
          _selectedSort = value;
          _visibleCount = 6;
        });

        Navigator.pop(context);
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts;

    final visibleProducts =
        filteredProducts.take(_visibleCount).toList();

    final hasMore =
        _visibleCount < filteredProducts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'LUXORA',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(
              Icons.shopping_bag_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CartScreen(),
                ),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          int columns = 2;

          if (constraints.maxWidth >= 1100) {
            columns = 4;
          } else if (constraints.maxWidth >= 700) {
            columns = 3;
          }

          return RefreshIndicator(
            onRefresh: () async {
              _resetVisibleProducts();
            },

            child: CustomScrollView(
              controller: _scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(),

              slivers: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover your style',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Explore our latest collection',
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Search
                        TextField(
                          controller:
                              _searchController,
                          decoration:
                              InputDecoration(
                            hintText:
                                'Search products...',
                            prefixIcon:
                                const Icon(
                              Icons.search,
                            ),
                            suffixIcon:
                                _searchController
                                        .text
                                        .isNotEmpty
                                    ? IconButton(
                                        icon:
                                            const Icon(
                                          Icons.clear,
                                        ),
                                        onPressed: () {
                                          _searchController
                                              .clear();
                                        },
                                      )
                                    : null,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Category + Sort
                        Row(
                          children: [
                            Expanded(
                              child:
                                  SingleChildScrollView(
                                scrollDirection:
                                    Axis.horizontal,
                                child: Row(
                                  children:
                                      _categories.map(
                                    (category) {
                                      final selected =
                                          _selectedCategory ==
                                              category;

                                      return Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          right: 8,
                                        ),
                                        child:
                                            ChoiceChip(
                                          label:
                                              Text(
                                            category,
                                          ),
                                          selected:
                                              selected,
                                          onSelected:
                                              (_) {
                                            setState(() {
                                              _selectedCategory =
                                                  category;
                                              _visibleCount =
                                                  6;
                                            });

                                            if (_scrollController
                                                .hasClients) {
                                              _scrollController
                                                  .jumpTo(0);
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            IconButton(
                              tooltip: 'Sort',
                              onPressed:
                                  _showSortOptions,
                              icon: const Icon(
                                Icons
                                    .sort,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ------------------------------------------------
                // PRODUCT COUNT
                // ------------------------------------------------

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      14,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${filteredProducts.length} products',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        if (_selectedSort !=
                            'Default')
                          Text(
                            _selectedSort,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ------------------------------------------------
                // EMPTY SEARCH/FILTER STATE
                // ------------------------------------------------

                if (filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          32,
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .search_off_outlined,
                              size: 64,
                              color:
                                  Colors.grey.shade400,
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            const Text(
                              'No products found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              'Try a different search or category.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            OutlinedButton(
                              onPressed: () {
                                _searchController
                                    .clear();

                                setState(() {
                                  _selectedCategory =
                                      'All';
                                  _selectedSort =
                                      'Default';
                                  _visibleCount = 6;
                                });
                              },
                              child: const Text(
                                'Clear Filters',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  // ------------------------------------------------
                  // PRODUCT GRID
                  // ------------------------------------------------
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ),
                    sliver: SliverGrid(
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          // Loading item
                          if (index >=
                              visibleProducts.length) {
                            return const Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(
                                  20,
                                ),
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2.5,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Loading more products...',
                                      style:
                                          TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final product =
                              visibleProducts[
                                  index];

                          return _ProductCard(
                            product: product,
                          );
                        },

                        childCount:
                            visibleProducts.length +
                                (hasMore ? 1 : 0),
                      ),

                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 0.68,
                      ),
                    ),
                  ),

                // ------------------------------------------------
                // END / LOADING MESSAGE
                // ------------------------------------------------

                if (_isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        bottom: 28,
                      ),
                      child: Center(
                        child: Text(
                          'Loading more products...',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (!hasMore &&
                    filteredProducts.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 8,
                        bottom: 32,
                      ),
                      child: Center(
                        child: Text(
                          'You\'ve reached the end of the collection',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================================================================
// PRODUCT CARD
// ==================================================================

class _ProductCard extends StatefulWidget {
  final Product product;

  const _ProductCard({
    required this.product,
  });

  @override
  State<_ProductCard> createState() =>
      _ProductCardState();
}

class _ProductCardState
    extends State<_ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },

      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },

      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        curve: Curves.easeOut,

        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),

        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior:
              Clip.antiAlias,

          elevation:
              _isHovered ? 6 : 1,

          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailsScreen(
                    product: product,
                  ),
                ),
              );
            },

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ------------------------------------------------
                // PRODUCT IMAGE
                // ------------------------------------------------

                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
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
                              size: 36,
                            ),
                          );
                        },
                      ),

                      // Hover overlay
                      AnimatedOpacity(
                        duration:
                            const Duration(
                          milliseconds: 150,
                        ),
                        opacity:
                            _isHovered ? 1 : 0,

                        child: Container(
                          color: Colors.black
                              .withValues(
                            alpha: 0.10,
                          ),

                          child:
                              const Center(
                            child: Icon(
                              Icons
                                  .visibility_outlined,
                              color:
                                  Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // PRODUCT INFORMATION
                // ------------------------------------------------

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    12,
                    10,
                    12,
                    12,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 15,
                            color:
                                Colors.amber,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            product.rating
                                .toString(),
                            style:
                                TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: [
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',

                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 150,
                            ),

                            padding:
                                const EdgeInsets
                                    .all(6),

                            decoration:
                                BoxDecoration(
                              color: _isHovered
                                  ? Colors.black
                                  : Colors
                                      .transparent,

                              shape:
                                  BoxShape.circle,
                            ),

                            child: Icon(
                              Icons
                                  .arrow_forward,
                              size: 17,

                              color: _isHovered
                                  ? Colors.white
                                  : Colors.black,
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
        ),
      ),
    );
  }
}