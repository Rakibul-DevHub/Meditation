/**

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




*/





import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:outdoor_therapy/features/views/splash/splash_screen.dart';
import 'core/services/notification_service.dart';
import 'core/dependency_injection/bindings.dart';
import 'core/download_service.dart';
import 'features/views/now_playing/audio_handler.dart';
import 'firebase_options.dart';

late MyAudioHandler audioHandler;

/// ✅ BACKGROUND & TERMINATED STATE HANDLER — always shows a POPUP.
///
/// IMPORTANT: When the app is fully terminated, this runs in a brand-new
/// isolate spawned just for this call. Nothing from your running app
/// (including any earlier plugin initialization) carries over here —
/// that's why we explicitly re-init Firebase AND the local notifications
/// plugin below before trying to show anything.
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  debugPrint("📬 Background Notification Received:");
  debugPrint("📬 Title: ${message.notification?.title}");
  debugPrint("📬 Body: ${message.notification?.body}");

  final NotificationService notificationService = NotificationService();

  // ✅ Set up the local notifications plugin + Android channel in THIS
  // isolate. Without this, .show() below can silently fail.
  await notificationService.initForBackgroundIsolate();

  // ✅ Explicit: this isolate is never "foreground", so this always
  // takes the popup/heads-up branch inside showLocalNotification().
  notificationService.setAppState(false);

  final notification = message.notification;
  if (notification != null) {
    await notificationService.showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title ?? 'New Notification',
      body: notification.body ?? '',
      payload: message.data['click_action'] ?? '',
    );
  } else {
    debugPrint("⚠️ message.notification is null in background handler — "
        "check if this is a data-only FCM payload, which won't auto-populate this field.");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint("✅ Firebase initialized successfully");

    // 2. Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // 3. Initialize Notification Service (full init: permissions + listeners)
    NotificationService notificationService = NotificationService();
    await notificationService.initNotification();

    // 4. Get and log FCM token
    String token = await notificationService.getFcmToken();
    if (token.isNotEmpty) {
      debugPrint("📱 FCM Token: $token");
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ✅ App process is alive and in front → treat as foreground.
    // (Covers normal launch. Covers "opened from terminated via tap"
    // too, since by the time this runs the UI is in front.)
    _notificationService.setAppState(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // ✅ Only `resumed` counts as foreground. Everything else
    // (inactive, paused, detached, hidden) → popup behavior.
    final bool isInForeground = state == AppLifecycleState.resumed;
    _notificationService.setAppState(isInForeground);

    debugPrint("📱 App lifecycle: $state → foreground=$isInForeground");
  }

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