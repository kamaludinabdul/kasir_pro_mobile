import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getProducts(String storeId) {
    return _db
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getCategories(String storeId) {
    return _db
        .collection('categories')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> createTransaction(Map<String, dynamic> transactionData) async {
    await _db.collection('transactions').add(transactionData);

    // Update stock logic would go here (using batch write)
    // For simplicity in this demo, we just record the transaction
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    await _db.collection('products').add(productData);
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    await _db.collection('products').doc(productId).update(productData);
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  Stream<List<Map<String, dynamic>>> getTransactions(String storeId) {
    return _db
        .collection('transactions')
        .where('storeId', isEqualTo: storeId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    await _db.collection('categories').add(categoryData);
  }

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> categoryData,
  ) async {
    await _db.collection('categories').doc(categoryId).update(categoryData);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }
}
