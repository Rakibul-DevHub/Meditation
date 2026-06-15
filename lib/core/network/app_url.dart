class AppUrl {
  AppUrl._();

  /// auth
  static const String baseUrl = 'https://mohaimin8001.sobhoy.com/api/v1';
  static const String imageBaseUrl = 'https://mohaimin8001.sobhoy.com';
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
  // static String trackDetails(String id) => '$baseUrl/app/tracks/$id';
  static String playTrack(String id) => '$baseUrl/app/tracks/$id';
  static const String playHistory = '$baseUrl/app/play-history';
  static const String getFavorite = '$baseUrl/app/favourites';
  static String addFavorites (String id) => '$baseUrl/app/favourites/$id';
  static String removeFavorites (String id) => '$baseUrl/app/favourites/$id';
  static String downloadSounds (String id) => '$baseUrl/app/downloads/$id';
  static String completeDownloadSoundsStatus (String id) => '$baseUrl/app/downloads/$id';
  static String downloadedSoundsList  = '$baseUrl/app/downloads';
  static String deleteDownloadSounds (String id) => '$baseUrl/app/downloads/$id';

  /// profile
  static const String getMyProfile  = '$baseUrl/app/profile/me';
  static const String updateMyProfile  = '$baseUrl/app/profile/me';

  /// settings
  static const String termsOfService  = '$baseUrl/app/cms/terms-conditions';
  static const String privacyPolicy  = '$baseUrl/app/cms/privacy-policies';

  /// subscription
  static const String getSubscriptionPlans  = '$baseUrl/app/subscriptions/plans';
  static const String getSubscriptionStatus  = '$baseUrl/app/subscriptions/status';
  static const String subscribeToPlan  = '$baseUrl/app/subscriptions/create-checkout';


}
