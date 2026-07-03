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
