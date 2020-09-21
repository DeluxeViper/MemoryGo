import 'package:MemoryGo/values/constants.dart';
import 'package:MemoryGo/screens/home/studyset_list.dart';
import 'package:MemoryGo/utils/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.getInstance().then((prefs) {
    // String primaryColor = prefs.getString('primaryColor');
    int primaryColor = prefs.getInt('primaryColor');
    if (primaryColor != null) {
      // String colorValueString = primaryColor.split('(0x')[1].split(')')[0];
      // int colorValue = int.parse(colorValueString, radix: 16);
      kPrimaryColor = Color(primaryColor);
    }
    runApp(ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(appTheme),
      child: MemoryGoApp(),
    ));
  });
}

class MemoryGoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'MemoryGo',
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.getTheme(),
      home: StudySetList(title: 'MemoryGo'),
    );
  }
}
