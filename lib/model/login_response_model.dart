/**
class LoginResponseModel {
  final bool success;
  final String? message;
  final LoginData? data;
  final String? token;
  final int? statusCode;

  LoginResponseModel({
    required this.success,
    this.message,
    this.data,
    this.token,
    this.statusCode,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      token: json['token'] ?? json['accessToken'],
      statusCode: json['statusCode'],
    );
  }
}

class LoginData {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;

  LoginData({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
    );
  }
}*/













class LoginResponseModel {
  final bool success;
  final String? message;
  final LoginData? data;
  final String? token;
  final int? statusCode;

  LoginResponseModel({
    required this.success,
    this.message,
    this.data,
    this.token,
    this.statusCode,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // ✅ Extract token from: data -> tokens -> access -> token
    String? extractedToken;
    try {
      final data = json['data'];
      if (data != null && data['tokens'] != null) {
        extractedToken = data['tokens']['access']['token'];
      }
    } catch (_) {}

    // Fallback to root-level token fields if nested not found
    extractedToken ??= json['token'] ?? json['accessToken'];

    return LoginResponseModel(
      success: json['success'] ?? json['status'] == 'OK',
      message: json['message'],
      data: json['data'] != null && json['data']['user'] != null
          ? LoginData.fromJson(json['data']['user'])
          : null,
      token: extractedToken,
      statusCode: json['statusCode'] ?? json['code'],
    );
  }
}

class LoginData {
  final String? id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;

  LoginData({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
    };
  }
}