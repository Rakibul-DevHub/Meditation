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
}