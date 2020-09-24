import 'package:MemoryGo/values/constants.dart';
import 'package:MemoryGo/screens/home/studyset_list.dart';
import 'package:MemoryGo/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MemoryGo/screens/onboarding/onboarding_screen.dart';

int initScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt('initScreen');
  await prefs.setInt('initScreen', 1);
  int primaryColor = prefs.getInt('primaryColor');
  if (primaryColor != null) {
    kPrimaryColor = Color(primaryColor);
  }
  runApp(ChangeNotifierProvider<ThemeNotifier>(
    create: (_) => ThemeNotifier(appTheme),
    child: MemoryGoApp(),
  ));
}

class MemoryGoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'MemoryGo',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      initialRoute:
          initScreen == 0 || initScreen == null ? '/onboard' : '/homepage',
      routes: {
        '/homepage': (context) => StudySetList(
              title: 'MemoryGo',
            ),
        '/onboard': (context) => OnBoardingScreen(),
      },
      // home: StudySetList(title: 'MemoryGo'),
    );
  }
}
