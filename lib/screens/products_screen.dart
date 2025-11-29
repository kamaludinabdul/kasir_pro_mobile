import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy =
      'name_asc'; // name_asc, name_desc, price_asc, price_desc, stock_asc, stock_desc

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final storeId = user?['storeId'];
    final db = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produk',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name_asc', child: Text('Nama (A-Z)')),
              const PopupMenuItem(
                value: 'name_desc',
                child: Text('Nama (Z-A)'),
              ),
              const PopupMenuItem(
                value: 'price_asc',
                child: Text('Harga (Termurah)'),
              ),
              const PopupMenuItem(
                value: 'price_desc',
                child: Text('Harga (Termahal)'),
              ),
              const PopupMenuItem(
                value: 'stock_asc',
                child: Text('Stok (Sedikit)'),
              ),
              const PopupMenuItem(
                value: 'stock_desc',
                child: Text('Stok (Banyak)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Category Filter - Fetch from Database
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: db.getCategories(storeId),
            builder: (context, categorySnapshot) {
              List<String> categories = ['Semua'];

              if (categorySnapshot.hasData &&
                  categorySnapshot.data!.isNotEmpty) {
                categories.addAll(
                  categorySnapshot.data!
                      .map((cat) => cat['name'] as String)
                      .toList(),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected)
                            setState(() => _selectedCategory = category);
                        },
                        selectedColor: const Color(0xFF6366F1),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: db.getProducts(storeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada produk"));
                }

                var products = snapshot.data!;

                // 1. Filter by Category
                if (_selectedCategory != 'Semua') {
                  products = products
                      .where((p) => p['category'] == _selectedCategory)
                      .toList();
                }

                // 2. Filter by Search Query
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) {
                    final name = (p['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                // 3. Sort
                products.sort((a, b) {
                  switch (_sortBy) {
                    case 'name_asc':
                      return (a['name'] ?? '').compareTo(b['name'] ?? '');
                    case 'name_desc':
                      return (b['name'] ?? '').compareTo(a['name'] ?? '');
                    case 'price_asc':
                      return (a['sellPrice'] ?? 0).compareTo(
                        b['sellPrice'] ?? 0,
                      );
                    case 'price_desc':
                      return (b['sellPrice'] ?? 0).compareTo(
                        a['sellPrice'] ?? 0,
                      );
                    case 'stock_asc':
                      return (a['stock'] ?? 0).compareTo(b['stock'] ?? 0);
                    case 'stock_desc':
                      return (b['stock'] ?? 0).compareTo(a['stock'] ?? 0);
                    default:
                      return 0;
                  }
                });

                if (products.isEmpty) {
                  return const Center(child: Text("Produk tidak ditemukan"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8), // Spacing for cards
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final price = product['sellPrice'] ?? product['price'] ?? 0;
                    final stock = product['stock'] ?? 0;

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                        title: Text(
                          product['name'],
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price)}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF18181B),
                              ),
                            ),
                            Text(
                              'Stok: $stock | ${product['category'] ?? '-'}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFFA1A1AA),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Color(0xFFA1A1AA),
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductFormScreen(product: product),
                                ),
                              );
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Produk?'),
                                  content: Text(
                                    'Apakah Anda yakin ingin menghapus ${product['name']}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await db.deleteProduct(product['id']);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produk berhasil dihapus'),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductFormScreen(product: product),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
