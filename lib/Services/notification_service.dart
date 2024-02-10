import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import '../Constants/app_colors.dart';
import '../Constants/constant.dart';

class NotificationService {
  NotificationService();

  final localNotifications = FlutterLocalNotificationsPlugin();
  late AndroidNotificationChannel channel;

  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  // AS PER PLATFORM NOTIFICATION HAS BEEN INITIALIZE.
  Future<void> initializePlatformNotifications() async {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    // Initialization settings for android.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for IOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    // Set both settings into InitializationSettings.
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize local Notification.
    await localNotifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: selectNotification);

    // Subscribe to Topic for getting Notification.
    FirebaseMessaging.instance.subscribeToTopic(Constants.subscriberTopic);

    if (Platform.isIOS) {
      // Request for notification permission.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    debugPrint('id $id');
  }

  Future<String?> getFCMToken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    try {
     Constants.fcmToken = await firebaseMessaging.getToken();
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }
  void selectNotification(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null &&
        notificationResponse.payload!.isNotEmpty) {
      behaviorSubject.add(notificationResponse.payload!);
    }
  }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'channel id',
      'channel name',
      groupKey: 'com.example.flutter_push_notifications',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      color: AppColors.primaryColor,
    );

    DarwinNotificationDetails iosNotificationDetails =
        const DarwinNotificationDetails(
      threadIdentifier: "thread1",
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    final NotificationDetails platformChannelSpecifics =
        await _notificationDetails();
    await localNotifications.show(
      0,
      body,
      title,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
