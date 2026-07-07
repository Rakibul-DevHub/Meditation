import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  int _id = 0;
  bool _isAppInForeground = false;

  void setAppState(bool isInForeground) {
    _isAppInForeground = isInForeground;
  }

  Future<void> initNotification() async {
    if (_isInitialized) return;

    try {
      debugPrint("🔄 Initializing Notification Service...");

      await _requestPermission();
      await _initLocalNotifications();
      _setupForegroundListener();
      _setupBackgroundTapHandler();
      await _handleTerminatedState();
      await getFcmToken();

      // ✅ Diagnostic: confirm the OS actually allows notifications
      final enabled = await areNotificationsEnabled();
      debugPrint("🔔 Notifications enabled at OS level: $enabled");

      _isInitialized = true;
      debugPrint("✅ Notification Service Initialized Successfully!");
    } catch (e) {
      debugPrint("❌ Error initializing notification service: $e");
    }
  }

  /// ✅ Request Firebase (iOS) + Android 13+ runtime permission
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        criticalAlert: true,
        sound: true,
        provisional: false,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          debugPrint("✅ Permission granted by user");
          break;
        case AuthorizationStatus.provisional:
          debugPrint("✅ Permission granted provisionally");
          break;
        default:
          debugPrint("❌ Permission denied by user");
      }

      // ✅ Android 13+ (API 33+) requires this explicit runtime request.
      // Without it, .show() silently does nothing even if the channel
      // is set up correctly.
      final androidImpl = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImpl?.requestNotificationsPermission();
      debugPrint("🔔 Android POST_NOTIFICATIONS granted: $granted");
    } catch (e) {
      debugPrint("❌ Error requesting permission: $e");
    }
  }

  /// ✅ Use this in background isolates (e.g. inside your
  /// @pragma('vm:entry-point') background message handler in main.dart).
  ///
  /// When the app is fully terminated, Firebase spawns a brand-new,
  /// separate isolate just to run that handler. The `NotificationService`
  /// singleton in that isolate has NEVER had `.initialize()` called on
  /// the local notifications plugin, and the Android channel was never
  /// created there. Calling `showLocalNotification()` without this first
  /// can silently fail. This method sets up ONLY what's needed to show
  /// a notification — no permission requests, no FCM listeners — since
  /// those aren't relevant/reliable in a short-lived background isolate.
  Future<void> initForBackgroundIsolate() async {
    if (_isInitialized) return; // already set up (app was in memory)
    try {
      await _initLocalNotifications();
      debugPrint("✅ Local notifications ready in background isolate");
    } catch (e) {
      debugPrint("❌ Error initializing local notifications in background isolate: $e");
    }
  }

  /// ✅ Call this any time to check if the OS is actually allowing
  /// notifications to be shown (independent of your app's own flags).
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImpl = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await androidImpl?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      debugPrint("❌ Error checking notification permission: $e");
      return false;
    }
  }

  Future<String> getFcmToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint("📱 FCM Token: $token");
        return token;
      }
      return "";
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
      return "";
    }
  }

  Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(
        defaultActionName: 'Open notification',
      );

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS,
        linux: initializationSettingsLinux,
      );

      await _localNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse:
        _onBackgroundNotificationTap,
      );

      await _createAndroidChannel();
      debugPrint("✅ Local notifications initialized");
    } catch (e) {
      debugPrint("❌ Error initializing local notifications: $e");
    }
  }

  /// ⚠️ NOTE: Android notification channels are IMMUTABLE once created.
  /// If you previously ran this app with a different importance/config
  /// for this same channel ID, this call is a no-op on that device.
  /// Uninstall the app (not just hot restart) or change _channelId
  /// to force a fresh channel when testing changes here.
  Future<void> _createAndroidChannel() async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped');
    debugPrint('Payload: ${response.payload}');
    _handleNavigation(response.payload);
  }

  void _onBackgroundNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Background notification tapped');
    debugPrint('Payload: ${response.payload}');
    _handleNavigation(response.payload);
  }

  /// ✅ Show notification based on app state.
  /// Foreground: shows quietly in the notification panel.
  /// Background/terminated: shows as a full popup/heads-up.
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      AndroidNotificationDetails androidNotificationDetails;

      if (_isAppInForeground) {
        // ✅ FOREGROUND: still shown in the notification panel,
        // just without the heads-up/full-screen behavior.
        debugPrint("📱 Foreground - Notification panel");
        androidNotificationDetails = const AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high, // must be >= channel's importance
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
          icon: '@mipmap/ic_launcher', // explicit — avoids null-icon drops
        );
      } else {
        // ✅ BACKGROUND/TERMINATED: full popup
        debugPrint("📱 Background/Terminated - POPUP on screen");
        androidNotificationDetails = const AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          icon: '@mipmap/ic_launcher',
        );
      }

      const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const LinuxNotificationDetails linuxNotificationDetails =
      LinuxNotificationDetails(
        urgency: LinuxNotificationUrgency.critical,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
        macOS: darwinNotificationDetails,
        linux: linuxNotificationDetails,
      );

      await _localNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );

      debugPrint('✅ Notification shown: $title (foreground=$_isAppInForeground)');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  /// ✅ FOREGROUND STATE
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📨 Foreground Notification Received");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");

      final notification = message.notification;
      if (notification != null) {
        _id++;
        showLocalNotification(
          id: _id,
          title: notification.title ?? 'New Notification',
          body: notification.body ?? '',
          payload: message.data['click_action'] ?? '',
        );
      } else {
        debugPrint("⚠️ message.notification is null — check if this is a data-only message");
      }
    });
  }

  void _setupBackgroundTapHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 App opened from background notification');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Data: ${message.data}');
      _handleNavigation(message.data['click_action']);
    });
  }

  Future<void> _handleTerminatedState() async {
    try {
      RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        debugPrint('📱 App opened from terminated state');
        debugPrint('Title: ${initialMessage.notification?.title}');
        _handleNavigation(initialMessage.data['click_action']);
      }
    } catch (e) {
      debugPrint('❌ Error handling terminated state: $e');
    }
  }

  void _handleNavigation(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      debugPrint('🔀 Navigating to: $payload');
      // Add your navigation logic here
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }
}