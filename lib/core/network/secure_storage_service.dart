/**
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  static SecureStorageService get instance => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  final String _keyAccessToken  = 'ACCESS_TOKEN';
  final String _keyRefreshToken = 'REFRESH_TOKEN';
  final String _keyUserData     = 'USER_DATA';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _keyAccessToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _keyRefreshToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUserData, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _keyUserData);
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}*/



///
///
/// todo:: storing the refresh token
///
///
///




import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  static SecureStorageService get instance => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  final String _keyAccessToken  = 'ACCESS_TOKEN';
  final String _keyRefreshToken = 'REFRESH_TOKEN';
  final String _keyUserData     = 'USER_DATA';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _keyAccessToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _keyRefreshToken);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  /// Save both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  /// Save user data
  Future<void> saveUserData(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUserData, value: jsonEncode(user));
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _keyUserData);
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}