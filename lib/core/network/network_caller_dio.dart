import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Add this for custom HttpClient
import 'network_response_dio.dart';

class NetworkCallerDio {
  late final Dio _dio;

  NetworkCallerDio() {
    _dio = Dio(BaseOptions(
      // ⚡ Performance optimizations
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),

      // Enable gzip compression
      headers: {
        'Accept-Encoding': 'gzip, deflate',
      },

      // Don't follow redirects automatically (saves time)
      followRedirects: false,

      // Validate status
      validateStatus: (status) => status! < 500,
    ));

    // ⚡ Add interceptor for logging only in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: false, // Disable request logging for speed
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false, // Disable response body logging for speed
        error: true,
      ));
    }

    // ⚡ Custom HTTP client adapter for better performance
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.idleTimeout = const Duration(seconds: 10);
      client.connectionTimeout = const Duration(seconds: 10);
      // Enable connection pooling
      client.maxConnectionsPerHost = 10;
      return client;
    };
  }

  // Generic function to handle any HTTP request (GET, POST, PUT, DELETE)
  Future<NetworkResponseDio> _request(
      String method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    final Map<String, String> requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    // ⚡ Only log in debug mode and with minimal info
    if (kDebugMode) {
      debugPrint('🌐 $method: ${url.split('?').first}');
    }

    try {
      Response response;
      final options = Options(headers: requestHeaders);

      switch (method.toUpperCase()) {
        case 'POST':
          response = await _dio.post(
            url,
            data: jsonEncode(body),
            options: options,
          );
          break;

        case 'GET':
          response = await _dio.get(
            url,
            options: options,
          );
          break;

        case 'PUT':
          response = await _dio.put(
            url,
            data: jsonEncode(body),
            options: options,
          );
          break;

        case 'DELETE':
          response = await _dio.delete(
            url,
            data: body != null ? jsonEncode(body) : null,
            options: options,
          );
          break;

        case 'PATCH':
          response = await _dio.patch(
            url,
            data: jsonEncode(body),
            options: options,
          );
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (kDebugMode) {
        debugPrint('✅ Response: ${response.statusCode}');
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
        return 'Network error. Please try again.';
    }
  }

  // Helper method to extract error message from response
  String _extractErrorMessage(Map<String, dynamic> response) {
    // Priority 1: Check 'message' field
    if (response.containsKey('message') && response['message'] != null) {
      return response['message'].toString();
    }

    // Priority 2: Check 'error' array or object
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

  // Handles response from the HTTP request
  NetworkResponseDio _handleResponse(Response response, bool isLogin) {
    try {
      final Map<String, dynamic> jsonResponse = response.data is String
          ? jsonDecode(response.data)
          : Map<String, dynamic>.from(response.data);

      // Handle successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponseDio(
          isSuccess: true,
          jsonResponse: jsonResponse,
          statusCode: response.statusCode,
        );
      }

      // For all error responses, extract the message from the response body
      String errorMessage = _extractErrorMessage(jsonResponse);

      // Handle specific status codes with fallback messages
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

  // GET Request
  Future<NetworkResponseDio> getRequest(
      String url, {
        Map<String, String>? headers,
        bool isLogin = false,
      }) async {
    return _request('GET', url, headers: headers, isLogin: isLogin);
  }

  // POST Request
  Future<NetworkResponseDio> postRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('POST', url, body: body, isLogin: isLogin, headers: headers);
  }

  // PUT Request
  Future<NetworkResponseDio> putRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('PUT', url, body: body, isLogin: isLogin, headers: headers);
  }

  // DELETE Request
  Future<NetworkResponseDio> deleteRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('DELETE', url, body: body, isLogin: isLogin, headers: headers);
  }

  // PATCH Request
  Future<NetworkResponseDio> patchRequest(
      String url, {
        Map<String, dynamic>? body,
        bool isLogin = false,
        Map<String, String>? headers,
      }) async {
    return _request('PATCH', url, body: body, isLogin: isLogin, headers: headers);
  }
}