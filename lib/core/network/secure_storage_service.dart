import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton instance
  static final SecureStorageService _instance = SecureStorageService._internal();

  // This is what you call
  static SecureStorageService get instance => _instance;

  // Private constructor
  SecureStorageService._internal();

  // Instance variables
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _keyAccessToken = 'ACCESS_TOKEN';
  final String _keyRefreshToken = 'REFRESH_TOKEN';
  final String _keyUserData = 'USER_DATA';

  // Instance methods
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUserData, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _keyUserData);
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}