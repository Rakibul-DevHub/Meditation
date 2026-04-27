// // image_upload_service.dart
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:outdoor_therapy/core/network/secure_storage_service.dart';
// import 'app_url.dart';
// import 'network_caller_dio.dart';
//
// class ImageUploadService {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//
//   Future<String?> uploadProfileImage(File imageFile) async {
//     try {
//       final token = await SecureStorageService.instance.getAccessToken();
//
//       if (token == null) {
//         print('No access token found');
//         return null;
//       }
//
//       final Map<String, File> files = {
//         'profileImage': imageFile,
//       };
//
//       final response = await _networkCaller.putMultipartRequest(
//         AppUrl.updateMyProfile,
//         files: files,
//         headers: {'Authorization': 'Bearer $token'},
//       );
//
//       print('📡 Upload response status: ${response.statusCode}');
//       print('📡 Upload response success: ${response.isSuccess}');
//       print('📡 Upload response body: ${response.jsonResponse}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         // Try different paths to get the image URL
//         String? imageUrl;
//
//         // Path 1: data.attributes.updatedUser.profileImage.imageUrl
//         imageUrl = response.jsonResponse?['data']?['attributes']?['updatedUser']?['profileImage']?['imageUrl'];
//
//         // Path 2: data.attributes.profileImage.imageUrl
//         if (imageUrl == null) {
//           imageUrl = response.jsonResponse?['data']?['attributes']?['profileImage']?['imageUrl'];
//         }
//
//         // Path 3: data.profileImage.imageUrl
//         if (imageUrl == null) {
//           imageUrl = response.jsonResponse?['data']?['profileImage']?['imageUrl'];
//         }
//
//         if (imageUrl != null) {
//           print('✅ Image uploaded successfully: $imageUrl');
//           return _getFullImageUrl(imageUrl);
//         } else {
//           print('❌ Could not extract image URL from response');
//           return null;
//         }
//       }
//
//       print('❌ Upload failed: ${response.errorMessage}');
//       return null;
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     }
//   }
//
//   String _getFullImageUrl(String? imagePath) {
//     if (imagePath == null || imagePath.isEmpty) {
//       return "assets/images/dummy_user_image.png";
//     }
//     if (imagePath.startsWith('http')) {
//       return imagePath;
//     }
//     String cleanPath = imagePath;
//     if (cleanPath.startsWith('/')) {
//       cleanPath = cleanPath.substring(1);
//     }
//     return '${AppUrl.imageBaseUrl}/$cleanPath';
//   }
// }