import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'products_screen.dart';
import 'stock_management_screen.dart';
import 'categories_screen.dart';

class DatabaseScreen extends StatelessWidget {
  const DatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Database',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            context,
            'Produk',
            'Kelola daftar produk dan harga',
            Icons.inventory_2_outlined,
            Colors.purple,
            const ProductsScreen(),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            context,
            'Manajemen Stok',
            'Stok masuk, keluar, dan opname',
            Icons.warehouse_outlined,
            Colors.orange,
            const StockManagementScreen(),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            context,
            'Kategori',
            'Kelola kategori produk',
            Icons.category_outlined,
            Colors.teal,
            const CategoriesScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.inter(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}
