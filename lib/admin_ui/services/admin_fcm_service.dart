import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:html' as html;

class AdminFcmService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> init() async {
    if (!kIsWeb) return; //   

    //  Request notification permission
    final permission =
        await html.Notification.requestPermission();

    if (permission != 'granted') {
      print(' Notification permission not granted');
      return;
    }

    //  Get FCM token
    final token = await _messaging.getToken(
      vapidKey: 'BPmWSN-U3ZBlS5k-3aZWBgPWl1PWfnV-mRsdyCd-bDKH2dHJUhlEQcjgI8egRGAIZ3syeJCOeoGqPSZJ5U6bVxE',
    );

    print(' Admin FCM Token: $token');

    //   foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final title =
          message.notification?.title ?? 'New Notification';
      final body =
          message.notification?.body ?? '';

      _showBrowserNotification(
        title: title,
        body: body,
      );
    });
  }

  static void _showBrowserNotification({
    required String title,
    required String body,
  }) {
    html.Notification(
      title,
      body: body,
      icon: '/icons/Icon-192.png',
    );
  }
}

