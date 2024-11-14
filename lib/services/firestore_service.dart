import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/cache_manager.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheManager _cacheManager = CacheManager();

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  // Tab data operations
  Stream<QuerySnapshot> getTabData(String tabName) {
    try {
      return _firestore
          .collection(tabName)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
        print('Firestore error: $error');
        // Return empty snapshot instead of throwing
        return const Stream.empty();
      });
    } catch (e) {
      print('Error in getTabData: $e');
      return const Stream.empty();
    }
  }

  Future<List<Map<String, dynamic>>> getTabDataWithCache(String tabName) async {
    try {
      // Try to get cached data first
      final cachedData = await _cacheManager.getCachedTabData(tabName);
      if (cachedData != null) {
        return cachedData;
      }

      // If no cache or expired, fetch from Firestore
      final snapshot = await _firestore
          .collection(tabName)
          .orderBy('timestamp', descending: true)
          .get();

      await _cacheManager.cacheTabData(tabName, snapshot.docs);

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'data': data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching data: $e');
      // Return cached data if available, even if expired
      return await _cacheManager.getCachedTabData(tabName) ?? [];
    }
  }

  Future<void> addTabItem(String tabName, Map<String, dynamic> data) async {
    await _firestore.collection(tabName).add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTabItem(
      String tabName, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(tabName).doc(docId).update(data);
  }

  Future<void> deleteTabItem(String tabName, String docId) async {
    await _firestore.collection(tabName).doc(docId).delete();
  }
}
