import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(
    String storeName,
    String username,
    String pin,
  ) async {
    try {
      String? targetStoreId;

      // 1. If Store Name is provided, find the store
      if (storeName.isNotEmpty) {
        final storeQuery = await _db
            .collection('stores')
            .where('name', isEqualTo: storeName)
            .get();

        if (storeQuery.docs.isEmpty) {
          return {'success': false, 'message': 'Toko tidak ditemukan.'};
        }
        targetStoreId = storeQuery.docs.first.id;
      }

      // 2. Find User
      final userQuery = await _db
          .collection('users')
          .where('pin', isEqualTo: pin)
          .where('name', isEqualTo: username)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        final userData = userDoc.data();
        userData['id'] = userDoc.id;

        // 3. Verify Store Association
        if (userData['role'] == 'super_admin') {
          // Super Admin can log in from anywhere
        } else {
          // Regular user MUST match the store
          if (userData['storeId'] != targetStoreId) {
            return {
              'success': false,
              'message': 'User tidak terdaftar di toko ini.',
            };
          }
        }

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode(userData));

        return {'success': true, 'user': userData};
      } else {
        return {'success': false, 'message': 'Username atau PIN salah.'};
      }
    } catch (e) {
      print("Login error: $e");
      return {'success': false, 'message': 'Terjadi kesalahan saat login: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('currentUser');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }
}
