import 'package:MemoryGo/utils/theme_notifier.dart';
import 'package:MemoryGo/values/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsPage extends StatefulWidget {
  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            buildCardWidget(
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Text(
                          'About App',
                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: 'Developed By: ',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w300),
                          ),
                          TextSpan(
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () => launchUrl(
                                    'https://github.com/CeruleanSource'),
                              text: 'CeruleanSource',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue))
                        ], style: TextStyle(color: Colors.black))),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                text: 'Made With: ',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w300),
                              ),
                            ], style: TextStyle(color: Colors.black))),
                          ),
                          FlutterLogo(),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: Text('Flutter,'),
                          ),
                          Image(
                              height: 30,
                              width: 30,
                              image:
                                  AssetImage('assets/images/android_logo.png')),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text('Native Android'),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(
                                height: 30,
                                width: 30,
                                image: AssetImage(
                                    'assets/icons/linkedin_icon.png')),
                          ),
                          RichText(
                              text: TextSpan(
                                  text: 'Follow our LinkedIn page',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () => launchUrl(
                                        'https://www.linkedin.com/company/67244556/'))),
                        ],
                      ),
                    ],
                  ),
                ),
                context),
            buildCardWidget(
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: Text(
                          'Theme Color',
                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          height: 250,
                          child: MaterialColorPicker(
                            selectedColor: kPrimaryColor,
                            allowShades: true,
                            onColorChange: (Color color) {
                              print(color);
                              setState(() {
                                kPrimaryColor = color;
                              });
                              onThemeChanged(themeNotifier);
                            },
                            onMainColorChange: (ColorSwatch color) {
                              // Handle main color changes
                            },
                          )),
                    ],
                  ),
                ),
                context),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'App Settings',
          style: TextStyle(color: kPrimaryColor),
        ));
  }

  Widget buildCardWidget(Widget child, BuildContext context) {
    return Container(
        margin: EdgeInsets.all(15),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 8),
                  color: Colors.black.withAlpha(20),
                  blurRadius: 16)
            ]),
        child: child);
  }

  void launchUrl(final String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
      );
    }
  }

  void onThemeChanged(ThemeNotifier themeNotifier) async {
    themeNotifier.setTheme(appTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt('primaryColor', kPrimaryColor.value);
  }
}
