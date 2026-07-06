import 'package:audio_service/audio_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:outdoor_therapy/features/views/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'core/dependency_injection/bindings.dart';
import 'core/download_service.dart';
import 'features/views/now_playing/audio_handler.dart';
import 'firebase_options.dart';

late MyAudioHandler audioHandler;

// ✅ FIXED: Background message handler with proper initialization
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  debugPrint("📬 Background Notification Received:");
  debugPrint("📬 Title: ${message.notification?.title}");
  debugPrint("📬 Body: ${message.notification?.body}");

  // You can also show a local notification here if needed
  // But Firebase will show the system notification by default
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint("✅ Firebase initialized successfully");

    // 2. Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // 3. Initialize Notification Service
    NotificationService notificationService = NotificationService();
    await notificationService.initNotification();

    // 4. Get and log FCM token
    String token = await notificationService.getFcmToken();
    if (token.isNotEmpty) {
      debugPrint("📱 FCM Token: $token");
      debugPrint("📱 Copy this token to test notifications");
    } else {
      debugPrint("⚠️ FCM Token is empty - check Firebase configuration");
    }

    // 5. System UI Configuration
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // 6. Audio Handler Setup
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.outdoor_therapy.audio',
        androidNotificationChannelName: 'Audio Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    debugPrint("✅ Audio handler initialized");

    // 7. Dependencies
    await Get.putAsync(() async => DownloadService());
    debugPrint("✅ Download service initialized");

  } catch (e) {
    debugPrint("❌ Error during initialization: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Outdoor Therapy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      initialBinding: AppBindings(),
    );
  }
}