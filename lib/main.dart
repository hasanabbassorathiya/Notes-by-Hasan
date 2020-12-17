import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/route_manager.dart';
import 'package:notes/Controller/Root.dart';
import 'package:notes/Controller/Styles.dart';
import 'package:notes/Controller/bindings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences prefs;
  bool isDarkTheme = false;

  getTheme() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      print('isDarkTheme : ' + isDarkTheme.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = false;
    return GetMaterialApp(
      enableLog: true,
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      home: Root(),
      theme: Styles.themeData(isDarkTheme, context),
    );
  }

  @override
  void initState() {
    getTheme();
    Get.changeTheme(Styles.themeData(isDarkTheme, context));
    super.initState();
  }
}
