import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'network_response_dio.dart';
import 'secure_storage_service.dart';
import 'token_refresh_service.dart';
import '../../features/views/onboard/onboard_screen.dart';

class NetworkCallerDio {
  late final Dio _dio;

  NetworkCallerDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Accept-Encoding': 'gzip, deflate',
      },
      followRedirects: false,
      validateStatus: (status) => status! < 500,
    ));

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ));
    }

    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.idleTimeout = const Duration(seconds: 10);
      client.connectionTimeout = const Duration(seconds: 10);
      client.maxConnectionsPerHost = 10;
      return client;
    };
  }

  // Adjusted signature to accept a factory generator function for FormData
  Future<NetworkResponseDio> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        FormData Function()? formDataFactory,
        Map<String, String>? headers,
        bool isLogin = false,
        bool isRetry = false,
      }) async {
    // Generate the fresh FormData instance if the factory exists
    final FormData? formData = formDataFactory?.call();

    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': formData != null ? 'multipart/form-data' : 'application/json',
      ...?headers,
    };

    if (!isLogin) {
      final accessToken = await SecureStorageService.instance.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $accessToken';
      }
    }

    if (kDebugMode) {
      debugPrint('🌐 $method: ${url.split('?').first}');
    }

    try {
      Response response;
      final options = Options(headers: requestHeaders);
      final dynamic activePayload = formData ?? (body != null ? jsonEncode(body) : null);

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(url, data: activePayload, options: options);
          break;
        case 'GET':
          response = await _dio.get(url, options: options);
          break;
        case 'PUT':
          response = await _dio.put(url, data: activePayload, options: options);
          break;
        case 'DELETE':
          response = await _dio.delete(url, data: activePayload, options: options);
          break;
        case 'PATCH':
          response = await _dio.patch(url, data: activePayload, options: options);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (kDebugMode) {
        debugPrint('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 401 && !isLogin && !isRetry) {
        if (kDebugMode) {
          debugPrint('🔄 401 received — attempting token refresh...');
        }

        final refreshed = await TokenRefreshService.instance.refreshAccessToken();

        if (refreshed) {
          // Re-runs with the same factory to successfully build a brand-new stream
          return _request(
            method,
            url,
            body: body,
            formDataFactory: formDataFactory,
            headers: headers,
            isLogin: isLogin,
            isRetry: true,
          );
        } else {
          await SecureStorageService.instance.clearAll();
          Get.offAll(() => const OnboardingScreen());
        }
      }

      return _handleResponse(response, isLogin);

    } on SocketException catch (e) {
      debugPrint('❌ Network error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        statusCode: null,
        errorMessage: 'No internet connection. Please check your network settings.',
      );
    } on DioException catch (e) {
      debugPrint('❌ DioError: ${e.type}');

      String errorMessage = _getDioErrorMessage(e);
      Map<String, dynamic>? errorResponse;

      if (e.response?.data != null) {
        try {
          final responseData = e.response?.data;
          if (responseData is String) {
            errorResponse = Map<String, dynamic>.from(jsonDecode(responseData));
          } else if (responseData is Map) {
            errorResponse = Map<String, dynamic>.from(responseData);
          }

          if (errorResponse != null) {
            errorMessage = _extractErrorMessage(errorResponse);
          }
        } catch (_) {}
      }

      return NetworkResponseDio(
        isSuccess: false,
        statusCode: e.response?.statusCode,
        jsonResponse: errorResponse,
        errorMessage: errorMessage,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server not responding. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Internal Error. Please try again.';
    }
  }

  String _extractErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey('message') && response['message'] != null) {
      return response['message'].toString();
    }
    if (response.containsKey('error')) {
      final errorData = response['error'];
      if (errorData is List && errorData.isNotEmpty) {
        if (errorData[0] is Map && errorData[0].containsKey('message')) {
          return errorData[0]['message'].toString();
        }
      } else if (errorData is Map && errorData.containsKey('message')) {
        return errorData['message'].toString();
      }
    }
    return response['message'] ?? 'Request failed';
  }

  NetworkResponseDio _handleResponse(Response response, bool isLogin) {
    try {
      final Map<String, dynamic> jsonResponse = response.data is String
          ? jsonDecode(response.data)
          : Map<String, dynamic>.from(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponseDio(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      String errorMessage = _extractErrorMessage(jsonResponse);

      switch (response.statusCode) {
        case 400:
          errorMessage = errorMessage != 'Request failed' ? errorMessage : 'Bad request.';
          break;
        case 401:
          errorMessage = 'Session expired. Please login again.';
          break;
        case 403:
          errorMessage = 'Access denied.';
          break;
        case 404:
          errorMessage = 'Resource not found.';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          break;
      }

      return NetworkResponseDio(
        isSuccess: false,
        statusCode: response.statusCode,
        jsonResponse: jsonResponse,
        errorMessage: errorMessage,
      );
    } catch (e) {
      return NetworkResponseDio(
        isSuccess: false,
        errorMessage: 'Error parsing response',
      );
    }
  }

  Future<NetworkResponseDio> getRequest(
      String url, {
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    return _request('GET', url, headers: headers, isLogin: isLogin);
  }

  Future<NetworkResponseDio> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('POST', url, body: body, isLogin: isLogin, headers: headers);
  }

  Future<NetworkResponseDio> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('PUT', url, body: body, isLogin: isLogin, headers: headers);
  }

  Future<NetworkResponseDio> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('DELETE', url, body: body, isLogin: isLogin, headers: headers);
  }

  Future<NetworkResponseDio> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        FormData Function()? formDataFactory,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('PATCH', url, body: body, formDataFactory: formDataFactory, isLogin: isLogin, headers: headers);
  }
}