import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'app_url.dart';
import 'secure_storage_service.dart';

/// Calls AppUrl.refreshToken to exchange the stored refresh token for a
/// fresh access token (and, if your backend rotates them, a fresh
/// refresh token too).
///
/// Uses its own bare Dio instance — deliberately NOT the same Dio/
/// NetworkCallerDio instance your normal API calls go through. If you
/// wire the 401-retry interceptor below into that instance, a failed
/// refresh call would otherwise itself trigger the same interceptor and
/// loop forever.
class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  static TokenRefreshService get instance => _instance;
  TokenRefreshService._internal();

  final Dio _dio = Dio();

  // If several requests hit 401 around the same time, only the first one
  // should actually call the refresh endpoint — everyone else just waits
  // for that same in-flight call to finish and reuses its result.
  Completer<bool>? _refreshCompleter;

  Future<bool> refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await SecureStorageService.instance.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('🔄 No refresh token stored — cannot refresh.');
        _refreshCompleter!.complete(false);
        return false;
      }

      debugPrint('🔄 POST: ${AppUrl.refreshToken}');

      final response = await _dio.post(
        AppUrl.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      debugPrint('📡 Refresh status: ${response.statusCode}');

      final jsonResponse = response.data;

      if (response.statusCode == 200 && jsonResponse != null) {
        // Matches the same shape your login response uses:
        // data.tokens.access.token / data.tokens.refresh.token
        final tokens = jsonResponse['data']?['tokens'];
        final newAccessToken = tokens?['access']?['token'];
        final newRefreshToken = tokens?['refresh']?['token'];

        if (newAccessToken != null && (newAccessToken as String).isNotEmpty) {
          await SecureStorageService.instance.saveAccessToken(newAccessToken);

          // Save the rotated refresh token if the backend sent a new one;
          // otherwise the existing one stays valid and untouched.
          if (newRefreshToken != null && (newRefreshToken as String).isNotEmpty) {
            await SecureStorageService.instance.saveRefreshToken(newRefreshToken);
          }

          debugPrint('✅ Access token refreshed');
          _refreshCompleter!.complete(true);
          return true;
        }
      }

      debugPrint('❌ Refresh failed — unexpected response shape');
      _refreshCompleter!.complete(false);
      return false;
    } on DioException catch (e) {
      // A 401/403 here means the refresh token itself is invalid or
      // expired — there's no recovering from that without a fresh login.
      debugPrint('❌ Refresh request failed: ${e.response?.statusCode} ${e.message}');
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected refresh error: $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}