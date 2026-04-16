class ResendOtpRequestModel {
  final String email;

  ResendOtpRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}