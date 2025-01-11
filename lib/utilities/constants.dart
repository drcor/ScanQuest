import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromRGBO(0, 168, 232, 1);
const kSecondaryColor = Color.fromRGBO(0, 52, 89, 1);
const kDetailsColor = Color.fromRGBO(254, 203, 52, 1);
const kTextColor = Colors.black;

final ThemeData defaultThemeData = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    secondary: kSecondaryColor,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: kPrimaryColor,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(kPrimaryColor),
      foregroundColor: WidgetStateProperty.all(Colors.white),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: "Rowdies",
    ),
    headlineMedium: TextStyle(
      fontFamily: "Rowdies",
    ),
    headlineSmall: TextStyle(fontFamily: "Rowdies"),
    titleLarge: TextStyle(
      fontFamily: "Rowdies",
    ),
    titleMedium: TextStyle(
      fontFamily: "Rowdies",
    ),
    titleSmall: TextStyle(fontFamily: "Rowdies"),
    labelLarge: TextStyle(
      fontFamily: "Rowdies",
    ),
    labelMedium: TextStyle(
      fontFamily: "Rowdies",
    ),
    labelSmall: TextStyle(
      fontFamily: "Rowdies",
    ),
    bodyLarge: TextStyle(
      fontFamily: "SourGummy",
    ),
    bodyMedium: TextStyle(
      fontFamily: "SourGummy",
    ),
    bodySmall: TextStyle(
      fontFamily: "SourGummy",
    ),
  ),
);
