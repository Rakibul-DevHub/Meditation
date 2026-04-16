class VerifyOtpResponseModel {
  final bool success;
  final String? message;
  final VerifyData? data;
  final int? statusCode;

  VerifyOtpResponseModel({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? VerifyData.fromJson(json['data']) : null,
      statusCode: json['statusCode'],
    );
  }
}

class VerifyData {
  final String? email;
  final String? token; // If your API returns a reset token
  final bool? isValid;

  VerifyData({
    this.email,
    this.token,
    this.isValid,
  });

  factory VerifyData.fromJson(Map<String, dynamic> json) {
    return VerifyData(
      email: json['email'],
      token: json['token'],
      isValid: json['isValid'],
    );
  }
}