/**

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class NotificationService{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void requestedNotificationPermission() async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: true,
      sound: true,

    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      debugPrint("Permision greanted by user");
    }
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      debugPrint("Permission granted Provisionally");
    }
    else{
      debugPrint("Permission denied by user");
    }
  }

  Future<String> getFcmToekn()async{
    String? token = await messaging.getToken();
    debugPrint("FCM Token: .$token");
    return token!;

  }
}








*/






import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // ✅ Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize all notification setups
  Future<void> initNotification() async {
    if (_isInitialized) {
      debugPrint("ℹ️ Notification Service already initialized");
      return;
    }

    try {
      debugPrint("🔄 Initializing Notification Service...");

      // 1. Request Permissions
      await requestedNotificationPermission();

      // 2. Setup Local Notifications for Foreground Support
      await _initLocalNotifications();

      // 3. Listen for Foreground Messages
      _listenToForegroundMessages();

      // 4. Handle Notification Taps
      _handleNotificationTaps();

      // 5. Handle App Opened from Terminated State
      await _handleTerminatedState();

      _isInitialized = true;
      debugPrint("✅ Notification Service Initialized Successfully!");
    } catch (e) {
      debugPrint("❌ Error initializing notification service: $e");
    }
  }

  /// Request Notification Permission
  Future<void> requestedNotificationPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        criticalAlert: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint("✅ Permission granted by user");
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint("✅ Permission granted Provisionally");
      } else {
        debugPrint("❌ Permission denied by user");
      }
    } catch (e) {
      debugPrint("❌ Error requesting permission: $e");
    }
  }

  /// Fetch FCM Token
  Future<String> getFcmToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint("📱 FCM Token: $token");
        return token;
      } else {
        debugPrint("⚠️ FCM Token is null or empty!");
        return "";
      }
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
      return "";
    }
  }

  /// Initialize local notifications
  Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // ✅ FIXED: initialize() takes a positional argument in v17+
      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 Notification tapped: ${response.payload}');
          _handleNavigation(response.payload);
        },
      );

      // Create channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      debugPrint("✅ Local notifications initialized");
    } catch (e) {
      debugPrint("❌ Error initializing local notifications: $e");
    }
  }

  /// Listen to messages when app is in foreground
  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📨 Foreground Notification Received");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");

      RemoteNotification? notification = message.notification;

      if (notification != null) {
        // ✅ FIXED: show() takes positional arguments in v17+
        _localNotificationsPlugin.show(
          notification.hashCode,                    // id (positional)
          notification.title ?? 'New Notification', // title (positional)
          notification.body ?? '',                  // body (positional)
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['click_action'] ?? '', // payload (optional positional)
        );
      }
    });
  }

  /// Handle notification taps when app is in background
  void _handleNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 App opened from notification click:');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Data: ${message.data}');

      _handleNavigation(message.data['click_action']);
    });
  }

  /// Handle app opened from terminated state
  Future<void> _handleTerminatedState() async {
    try {
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('📱 App opened from terminated state:');
        debugPrint('Title: ${initialMessage.notification?.title}');
        _handleNavigation(initialMessage.data['click_action']);
      }
    } catch (e) {
      debugPrint("❌ Error handling terminated state: $e");
    }
  }

  /// Handle navigation based on payload
  void _handleNavigation(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      debugPrint('🔀 Navigating to: $payload');
      // You can add navigation logic here
      // Example: Get.toNamed('/details', arguments: payload);
    }
  }
}