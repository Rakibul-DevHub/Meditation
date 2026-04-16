class VerifyOtpRequestModel {
  final String email;
  final String code;

  VerifyOtpRequestModel({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}