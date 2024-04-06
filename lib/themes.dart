import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';

class MyTheme {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black38,
    appBarTheme: AppBarTheme(color: Colors.black38),
    dividerColor: Colors.black38,
    brightness: Brightness.dark,
    iconTheme: IconThemeData(color: Colors.white),
    primaryColor: Colors.white,
    drawerTheme: DrawerThemeData(backgroundColor: Colors.black,scrimColor: Colors.white.withOpacity(0.2)),
    colorScheme: ColorScheme.dark(),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(color: Colors.white),
    drawerTheme: DrawerThemeData(backgroundColor: Colors.white)
  );
}
