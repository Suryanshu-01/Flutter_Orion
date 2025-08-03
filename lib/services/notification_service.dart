import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('Permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission: ${settings.authorizationStatus}');
        // Don't throw error, just log it
      }
    } catch (e) {
      print('Error requesting notification permission: $e');
      // Continue with initialization even if permission is denied
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  static Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> saveTokenToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, cannot save FCM token');
        return;
      }

      final token = await getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'notificationEnabled': true,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('FCM token saved successfully for user: ${user.uid}');
      } else {
        print('Failed to get FCM token');
        // Still mark as enabled but without token
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationEnabled': true,
          'fcmTokenError': 'Failed to get token',
        });
      }
    } catch (e) {
      print('Error saving FCM token: $e');
      // Don't throw error, just log it
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      
      // Show local notification
      await _showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'money_received_channel',
      'Money Received Notifications',
      channelDescription: 'Notifications for money received',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap when app is in foreground
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screen based on payload
  }

  static void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap when app is in background
    print('Notification tapped from background: ${message.data}');
    // You can navigate to specific screen based on message data
  }

  static Future<void> sendMoneyReceivedNotification({
    required String receiverUid,
    required String senderName,
    required double amount,
  }) async {
    try {
      // Get receiver's FCM token
      final receiverDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUid)
          .get();

      final receiverData = receiverDoc.data();
      final fcmToken = receiverData?['fcmToken'];
      final notificationEnabled = receiverData?['notificationEnabled'] ?? false;

      if (fcmToken == null || !notificationEnabled) {
        print('User has no FCM token or notifications disabled');
        return;
      }

      // Send notification via Cloud Function (you'll need to create this)
      // For now, we'll use a simple approach with Firestore trigger
      await FirebaseFirestore.instance.collection('notifications').add({
        'receiverUid': receiverUid,
        'senderName': senderName,
        'amount': amount,
        'type': 'money_received',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  static Future<void> disableNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'notificationEnabled': false,
    });
  }

  static Future<bool> isNotificationEnabled() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['notificationEnabled'] ?? false;
  }

  // Debug method to check notification status
  static Future<void> debugNotificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      print('User notification settings:');
      print('- notificationEnabled: ${data?['notificationEnabled']}');
      print('- fcmToken: ${data?['fcmToken'] != null ? 'Present' : 'Missing'}');
      print('- fcmTokenError: ${data?['fcmTokenError']}');
      print('- lastTokenUpdate: ${data?['lastTokenUpdate']}');

      // Check current permission status
      final settings = await _firebaseMessaging.getNotificationSettings();
      print('Current permission status: ${settings.authorizationStatus}');

      // Try to get token
      final token = await getToken();
      print('Current FCM token: ${token != null ? 'Present' : 'Missing'}');
    } catch (e) {
      print('Error in debugNotificationStatus: $e');
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  
  // Show local notification for background messages
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'money_received_channel',
    'Money Received Notifications',
    channelDescription: 'Notifications for money received',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    message.notification?.title ?? 'Money Received',
    message.notification?.body ?? 'You have received money!',
    platformChannelSpecifics,
  );
} 