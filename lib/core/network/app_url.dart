class AppUrl {
  AppUrl._();

  /// auth
  static const String baseUrl = 'http://206.162.244.11:8001/api/v1';
  static const String imageBaseUrl = 'http://206.162.244.11:8001';
  static const String registration = '$baseUrl/auth/register';
  static const String resendEmailOtp = '$baseUrl/auth/register';
  static const String verifyEmailOtp = '$baseUrl/auth/verify-email';
  static const String login = '$baseUrl/auth/login';
  static const String googleLogin = '$baseUrl/auth/google-login';

  /// Category & Tracks
  static const String categories = '$baseUrl/app/categories';
  static String categoryDetails(String id) => '$baseUrl/app/categories/$id';
  static String featuredSounds = '$baseUrl/app/tracks?isFeatured=true';
  static String sleepTonight = '$baseUrl/app/tracks?isSleepTonight=true';
  static String popularListening = '$baseUrl/app/tracks/popular';
  static String trackDetails(String id) => '$baseUrl/app/tracks/$id';
  static const String playHistory = '$baseUrl/app/play-history';
  static const String getFavorite = '$baseUrl/app/favourites';
  static String addFavorites (String id) => '$baseUrl/app/favourites/$id';
  static String downloadSounds (String id) => '$baseUrl/app/downloads/$id';

  /// profile
  static const String getMyProfile  = '$baseUrl/app/profile/me';


}
