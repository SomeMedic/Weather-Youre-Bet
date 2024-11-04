import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';

final ThemeData baseLigth = ThemeData.light(useMaterial3: true);
final ThemeData baseDark = ThemeData.dark(useMaterial3: true);

// Определяем основные цвета приложения с улучшенной палитрой
const MaterialColor primarySwatch = Colors.deepOrange;

// Основные цвета для светлой темы
const Color lightColor = Color(0xFFF8F9FA); // Более мягкий белый
const Color lightSurfaceColor = Color(0xFFFFFFFF);
const Color lightAccentColor = Color(0xFFFF7043); // Deep Orange 400
const Color lightSecondaryColor = Color(0xFF26A69A); // Teal 400

// Основные цвета для темной темы
const Color darkColor = Color(0xFF121212); // Material Dark
const Color darkSurfaceColor = Color(0xFF1E1E1E);
const Color darkAccentColor = Color(0xFFFF8A65); // Deep Orange 300
const Color darkSecondaryColor = Color(0xFF4DB6AC); // Teal 300

// OLED тема
const Color oledColor = Colors.black;
const Color oledSurfaceColor = Color(0xFF1A1A1A);

// Градиенты для светлой темы
const LinearGradient lightPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFF7043), // Deep Orange 400
    Color(0xFFFF8A65), // Deep Orange 300
  ],
);

const LinearGradient lightSecondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF26A69A), // Teal 400
    Color(0xFF4DB6AC), // Teal 300
  ],
);

// Градиенты для темной темы
const LinearGradient darkPrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFF8A65), // Deep Orange 300
    Color(0xFFFFAB91), // Deep Orange 200
  ],
);

const LinearGradient darkSecondaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF4DB6AC), // Teal 300
    Color(0xFF80CBC4), // Teal 200
  ],
);

// Градиенты для карточек
const LinearGradient lightCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 1.0],
  colors: [
    Color(0xFFFFFFFF),
    Color(0xFFF5F5F5),
  ],
);

const LinearGradient darkCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  stops: [0.0, 1.0],
  colors: [
    Color(0xFF1E1E1E),
    Color(0xFF2C2C2C),
  ],
);

ColorScheme colorSchemeLight = ColorScheme.fromSeed(
  seedColor: lightAccentColor,
  brightness: Brightness.light,
  primary: lightAccentColor,
  secondary: lightSecondaryColor,
  surface: lightSurfaceColor,
  background: lightColor,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.black87,
  onBackground: Colors.black87,
  tertiary: Color(0xFF66BB6A), // Green 400
  error: Color(0xFFE57373), // Red 300
);

ColorScheme colorSchemeDark = ColorScheme.fromSeed(
  seedColor: darkAccentColor,
  brightness: Brightness.dark,
  primary: darkAccentColor,
  secondary: darkSecondaryColor,
  surface: darkSurfaceColor,
  background: darkColor,
  onPrimary: Colors.black,
  onSecondary: Colors.white,
  onSurface: Colors.white70,
  onBackground: Colors.white70,
  tertiary: Color(0xFF81C784), // Green 300
  error: Color(0xFFEF5350), // Red 400
);

ThemeData lightTheme(
    Color? color, ColorScheme? colorScheme, bool edgeToEdgeAvailable) {
  return baseLigth.copyWith(
    brightness: Brightness.light,
    colorScheme: colorScheme
        ?.copyWith(
          brightness: Brightness.light,
          surface: baseLigth.colorScheme.surface,
        )
        .harmonized(),
    textTheme: GoogleFonts.ubuntuTextTheme(baseLigth.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: baseLigth.colorScheme.onSurface,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor:
            edgeToEdgeAvailable ? Colors.transparent : colorScheme?.surface,
      ),
    ),
    primaryColor: color,
    canvasColor: color,
    scaffoldBackgroundColor: color,
    cardTheme: CardTheme(
      color: color,
      elevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: color == oledColor ? Colors.transparent : colorScheme?.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: color,
      surfaceTintColor:
          color == oledColor ? Colors.transparent : colorScheme?.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: color,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: color,
      surfaceTintColor: color == oledColor ? Colors.transparent : colorScheme?.surfaceTint,
      indicatorColor: colorScheme?.primary.withOpacity(0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return GoogleFonts.ubuntu(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return GoogleFonts.ubuntu(
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            size: 20,
            color: colorScheme?.primary,
            opacity: 1.0,
          );
        }
        return IconThemeData(
          size: 20,
          color: colorScheme?.onSurface.withOpacity(0.7),
          opacity: 0.8,
        );
      }),
      height: 65,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: WidgetStateTextStyle.resolveWith(
        (Set<WidgetState> states) {
          return const TextStyle(fontSize: 14);
        },
      ),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightAccentColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: lightAccentColor.withOpacity(0.3),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: color == oledColor ? darkAccentColor : colorScheme?.primary,
      foregroundColor: Colors.black,
      elevation: 4,
      splashColor: darkSecondaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: lightAccentColor,
      thumbColor: lightAccentColor,
      inactiveTrackColor: lightAccentColor.withOpacity(0.3),
      overlayColor: lightAccentColor.withOpacity(0.2),
    ),
  );
}

ThemeData darkTheme(
    Color? color, ColorScheme? colorScheme, bool edgeToEdgeAvailable) {
  return baseDark.copyWith(
    brightness: Brightness.dark,
    colorScheme: colorScheme
        ?.copyWith(
          brightness: Brightness.dark,
          surface: baseDark.colorScheme.surface,
        )
        .harmonized(),
    textTheme: GoogleFonts.ubuntuTextTheme(baseDark.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: color,
      foregroundColor: baseDark.colorScheme.onSurface,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor:
            edgeToEdgeAvailable ? Colors.transparent : colorScheme?.surface,
      ),
    ),
    primaryColor: color,
    canvasColor: color,
    scaffoldBackgroundColor: color,
    cardTheme: CardTheme(
      color: color,
      elevation: 4,
      shadowColor: darkAccentColor.withOpacity(0.1),
      surfaceTintColor: color == oledColor ? Colors.transparent : colorScheme?.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: color,
      surfaceTintColor:
          color == oledColor ? Colors.transparent : colorScheme?.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: color,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: color,
      surfaceTintColor: color == oledColor ? Colors.transparent : colorScheme?.surfaceTint,
      indicatorColor: colorScheme?.primary.withOpacity(0.1),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return GoogleFonts.ubuntu(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return GoogleFonts.ubuntu(
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(
            size: 20,
            color: colorScheme?.primary,
            opacity: 1.0,
          );
        }
        return IconThemeData(
          size: 20,
          color: colorScheme?.onSurface.withOpacity(0.7),
          opacity: 0.8,
        );
      }),
      height: 65,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: WidgetStateTextStyle.resolveWith(
        (Set<WidgetState> states) {
          return const TextStyle(fontSize: 14);
        },
      ),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkAccentColor,
        foregroundColor: Colors.black,
        elevation: 2,
        shadowColor: darkAccentColor.withOpacity(0.3),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkAccentColor,
      foregroundColor: Colors.black,
      elevation: 4,
      splashColor: darkSecondaryColor.withOpacity(0.3),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: darkAccentColor,
      thumbColor: darkAccentColor,
      inactiveTrackColor: darkAccentColor.withOpacity(0.3),
      overlayColor: darkAccentColor.withOpacity(0.2),
    ),
  );
}
