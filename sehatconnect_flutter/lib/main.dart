import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SehatConnectApp());
}

class SehatConnectApp extends StatelessWidget {
  const SehatConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SehatConnect',
      debugShowCheckedModeBanner: false,
      
      // Official Pakistan Government Theme System
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF01411C), // Pakistan Green
        scaffoldBackgroundColor: const Color(0xFFF5F5F0), // Off-white Background
        
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF01411C),
          onPrimary: Colors.white,
          secondary: Color(0xFF01411C),
          onSecondary: Colors.white,
          background: Color(0xFFF5F5F0),
          surface: Colors.white,
          onSurface: Color(0xFF1A1A1A),
        ),

        // Custom Font configuration
        textTheme: GoogleFonts.sourceSerif4TextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          bodyLarge: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 15.0),
          bodyMedium: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13.5),
        ),

        // Bordered style Form fields (not underline)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Color(0xFF01411C), width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          labelStyle: const TextStyle(fontSize: 14.0, color: Colors.grey),
        ),

        // Green, full-width, slightly rounded buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF01411C),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0), // slightly rounded
            ),
            textStyle: GoogleFonts.sourceSerif4(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Rounded Cards (8px) with subtle shadow and border
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2.0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // 8px rounded
            side: BorderSide(
              color: const Color(0xFF01411C).withOpacity(0.1),
              width: 1.0,
            ),
          ),
        ),

        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.2),
          thickness: 1.0,
        ),
      ),
      
      home: const SplashPage(),
    );
  }
}
