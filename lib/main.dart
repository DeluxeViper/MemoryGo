import 'package:MemoryGo/constants.dart';
import 'package:MemoryGo/screens/studyset_list.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// NotificationAppLaunchDetails notificationAppLaunchDetails;
// WidgetsFlutterBinding.ensureInitialized();
// notificationAppLaunchDetails =
//     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
// await initNotifications(flutterLocalNotificationsPlugin);
// requestIOSPermissions(flutterLocalNotificationsPlugin);
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoryGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StudySetList(title: 'MemoryGo'),
    );
  }
}
