class AppUrl {
  AppUrl._();

  static const String baseUrl = 'http://206.162.244.11:8001/api/v1';
  static const String imageBaseUrl = 'http://206.162.244.11:8001';
  static const String registration = '$baseUrl/auth/register';
  static const String resendEmailOtp = '$baseUrl/auth/register';///---> tis will chane
  static const String verifyEmailOtp = '$baseUrl/auth/verify-email';
  static const String login = '$baseUrl/auth/login';

}
