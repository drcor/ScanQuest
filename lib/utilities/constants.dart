import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromRGBO(0, 168, 232, 1);
const kSecondaryColor = Color.fromRGBO(0, 52, 89, 1);
const kDetailsColor = Color.fromRGBO(254, 203, 52, 1);
const kTextColor = Colors.black;
const kAlertColor = Colors.red;

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
  textTheme: TextTheme(
    headlineLarge: const TextStyle(fontFamily: "Rowdies"),
    headlineMedium: const TextStyle(fontFamily: "Rowdies"),
    headlineSmall: const TextStyle(fontFamily: "Rowdies"),
    titleLarge: const TextStyle(fontFamily: "Rowdies"),
    titleMedium: const TextStyle(fontFamily: "Rowdies"),
    titleSmall: const TextStyle(fontFamily: "Rowdies"),
    labelLarge: const TextStyle(fontFamily: "Rowdies"),
    labelMedium: const TextStyle(fontFamily: "Rowdies"),
    labelSmall: const TextStyle(fontFamily: "Rowdies"),
    bodyLarge: TextStyle(
      fontFamily: "SourGummy",
      fontVariations: [FontVariation('wght', 900.0)],
    ),
    bodyMedium: const TextStyle(
      fontFamily: "SourGummy",
      fontVariations: [FontVariation('wght', 400.0)],
    ),
    bodySmall: const TextStyle(
      fontFamily: "SourGummy",
      fontVariations: [FontVariation('wght', 400.0)],
    ),
  ),
);

final kItemTitleStyle = TextStyle(
  fontFamily: "SourGummy",
  fontSize: 18,
  color: kTextColor,
  fontVariations: [FontVariation('wght', 400.0)],
);
