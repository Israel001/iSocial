import 'package:flutter/material.dart';

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color.fromARGB(255, 255, 202, 109),
  accentColor: Color.fromARGB(255, 244, 127, 101), // Secondary Color
  primaryColorLight: Color.fromARGB(255, 255, 253, 157),
  primaryColorDark: Color.fromARGB(255, 201, 153, 62),
  disabledColor: Color.fromARGB(255, 255, 176, 147), // Secondary Color - Light
  cardColor: Color.fromARGB(255, 189, 80, 58),// Secondary Color - Dark,
  textTheme: TextTheme(
    caption: TextStyle(color: Colors.black)
  )
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color.fromARGB(255, 255, 202, 109),
  accentColor: Color.fromARGB(255, 244, 127, 101), // Secondary Color
  primaryColorLight: Color.fromARGB(255, 255, 253, 157),
  primaryColorDark: Color.fromARGB(255, 201, 153, 62),
  disabledColor: Color.fromARGB(255, 255, 176, 147), // Secondary Color - Light
  cardColor: Color.fromARGB(255, 189, 80, 58) // Secondary Color - Dark
);

ThemeData getAdaptiveThemeData(brightness) {
  return brightness == 'dark' ? _darkTheme : _lightTheme;
}