import 'package:MemoryGo/model/NoteNotification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

final BehaviorSubject<NoteNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<NoteNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_memorygo');
  var initSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      didReceiveLocalNotificationSubject.add(
          NoteNotification(id: id, title: title, body: body, payload: payload));
    },
  );
  var initSettings =
      InitializationSettings(initSettingsAndroid, initSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initSettings,
      onSelectNotification: (payload) async {
    if (payload != null) {
      debugPrint('notification payload:  ' + payload);
    }
    selectNotificationSubject.add(payload);
  });
}

Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0', 'MemoryGo', 'Notification channel to send notes',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  // Not sure what this does
  await flutterLocalNotificationsPlugin.show(
      0, 'MemoryGo title', 'Note body', platformChannelSpecifics,
      payload: 'item x');
}

Future<void> turnOffNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> turnOffNotificaitonById(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

Future<void> scheduleNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String id,
    String title,
    String body,
    DateTime scheduleNotificationDateTime) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      id, 'MemoryGo notifications', 'Note notification',
      icon: '@mipmap/ic_memorygo');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.schedule(
      0, title, body, scheduleNotificationDateTime, platformChannelSpecifics);
}

Future<void> scheduleNotificationPeriodically(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String id,
    String title,
    String body,
    RepeatInterval interval) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      id, 'MemoryGo notifications', 'Note notification',
      icon: '@mipmap/ic_memorygo');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.periodicallyShow(
      0, title, body, interval, platformChannelSpecifics);
}

void requestIOSPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}
