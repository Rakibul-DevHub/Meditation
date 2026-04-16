class RegistrationResponseModel {
  final bool success;
  final String? message;
  final UserData? data;
  final int? statusCode;

  RegistrationResponseModel({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    return RegistrationResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

class UserData {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;

  UserData({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      role: json['role'],
    );
  }
}