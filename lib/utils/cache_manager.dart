import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const String _prefix = 'tab_data_';
  static const Duration cacheValidity = Duration(hours: 24);

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> cacheTabData(
      String tabName, List<QueryDocumentSnapshot> documents) async {
    final prefs = await _getPrefs();
    final timestamp = DateTime.now();

    final dataToCache = documents.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'data': data,
        'cachedAt': timestamp.toIso8601String(),
      };
    }).toList();

    await prefs.setString('${_prefix}${tabName}_data', jsonEncode(dataToCache));
    await prefs.setString(
        '${_prefix}${tabName}_timestamp', timestamp.toIso8601String());
  }

  Future<List<Map<String, dynamic>>?> getCachedTabData(String tabName) async {
    final prefs = await _getPrefs();
    final cachedTimestamp = prefs.getString('${_prefix}${tabName}_timestamp');

    if (cachedTimestamp == null) return null;

    final timestamp = DateTime.parse(cachedTimestamp);
    if (DateTime.now().difference(timestamp) > cacheValidity) {
      // Cache is expired
      await prefs.remove('${_prefix}${tabName}_data');
      await prefs.remove('${_prefix}${tabName}_timestamp');
      return null;
    }

    final cachedDataString = prefs.getString('${_prefix}${tabName}_data');
    if (cachedDataString == null) return null;

    final List<dynamic> decodedData = jsonDecode(cachedDataString);
    return decodedData.cast<Map<String, dynamic>>();
  }

  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<bool> isCacheValid(String tabName) async {
    final prefs = await _getPrefs();
    final cachedTimestamp = prefs.getString('${_prefix}${tabName}_timestamp');

    if (cachedTimestamp == null) return false;

    final timestamp = DateTime.parse(cachedTimestamp);
    return DateTime.now().difference(timestamp) <= cacheValidity;
  }
}
