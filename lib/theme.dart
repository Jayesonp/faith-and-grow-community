import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Get web-adjusted font size with proper scaling for different screen sizes
double _webAdjustedSize(double size, {double? desktopSize, double? tabletSize, double? mobileSize}) {
  if (!kIsWeb) return size.sp;
  
  // Get the window width
  final width = WidgetsBinding.instance.window.physicalSize.width / 
      WidgetsBinding.instance.window.devicePixelRatio;
  
  // Return size based on screen width
  if (width >= 1200) {
    return desktopSize ?? (size * 0.9); // Desktop - slightly reduced
  } else if (width >= 768) {
    return tabletSize ?? (size * 0.85); // Tablet - more reduced
  } else {
    return mobileSize ?? (size * 0.8); // Mobile - most reduced
  }
}

/// Typographic Scale
/// A consistent typographic scale for the entire application
class AppTypography {
  // Page titles
  static TextStyle pageTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 26.0 : 28.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      height: 1.3,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
  
  // Section titles
  static TextStyle sectionTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 22.0 : 24.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.3,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
  
  // Content titles
  static TextStyle contentTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 18.0 : 20.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
  
  // Subtitle text
  static TextStyle subtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 16.0 : 18.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
    );
  }
  
  // Body text
  static TextStyle bodyText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 14.0 : 16.sp,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.1,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
    );
  }
  
  // Button text
  static TextStyle buttonText(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 14.0 : 16.sp,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.4,
      color: Theme.of(context).colorScheme.primary,
    );
  }
  
  // Caption text
  static TextStyle caption(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 12.0 : 14.sp,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.2,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }
  
  // Small text
  static TextStyle small(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 10.0 : 12.sp,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.3,
      height: 1.3,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );
  }
  
  // Title large (added for compatibility)
  static TextStyle titleLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 18.0 : 20.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
  
  // Heading medium (added for compatibility)
  static TextStyle headingMedium(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 20.0 : 22.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.3,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
  
  // Body large (added for compatibility)
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: kIsWeb ? 16.0 : 18.sp,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.1,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87),
    );
  }
}

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF4CAF50), // Green color from Faith and Grow logo
        secondary: const Color(0xFFD4AF37), // Gold color from Faith and Grow logo
        tertiary: const Color(0xFF000000), // Black color from Faith and Grow logo
        surface: const Color(0xFFF1F4F8),
        error: const Color(0xFFFF5963),
        onPrimary: const Color(0xFFFFFFFF),
        onSecondary: const Color(0xFF15161E),
        onTertiary: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFF15161E),
        onError: const Color(0xFFFFFFFF),
        outline: const Color(0xFFB0BEC5),
      ),
      cardTheme: CardTheme(
        elevation: kIsWeb ? 1.0 : 2.0, // Lighter elevation for mobile (standard practice)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kIsWeb ? 8.0 : 8.r)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(
          vertical: kIsWeb ? 8.0 : 10.h,
          horizontal: kIsWeb ? 8.0 : 12.w,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: kIsWeb ? 16.0 : 16.w,
        centerTitle: true,
        toolbarHeight: kIsWeb ? 56.0 : 48.h, // Standard mobile height
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.0 : 16.w,
          vertical: kIsWeb ? 4.0 : 8.h, // More vertical padding for better touch targets
        ),
        minLeadingWidth: 24.w, // Standardized icon width
        titleTextStyle: GoogleFonts.inter(
          fontSize: kIsWeb ? 15.0 : 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12.sp),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12.sp),
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
      dividerTheme: DividerThemeData(
        space: 1.h,
        thickness: 1.0,
        color: Colors.grey.withOpacity(0.2),
      ),
      iconTheme: IconThemeData(
        size: 24.r, // Standard mobile icon size
        color: const Color(0xFF4CAF50),
      ),
      tooltipTheme: TooltipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        margin: EdgeInsets.all(8.r),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        sizeConstraints: BoxConstraints.tightFor(width: 56.r, height: 56.r),
        smallSizeConstraints: BoxConstraints.tightFor(width: 40.r, height: 40.r),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF4CAF50),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        contentTextStyle: GoogleFonts.inter(fontSize: 14.sp),
        actionTextColor: const Color(0xFFD4AF37),
      ),
      brightness: Brightness.light,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 42.0 : 48.sp, // Reduced from 54sp for better proportion
          fontWeight: FontWeight.normal,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 34.0 : 38.sp, // Reduced from 42sp for better proportion
          fontWeight: FontWeight.normal,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 28.0 : 30.sp, // Reduced from 34sp for better proportion
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 24.0 : 26.sp, // Reduced from 30sp for better proportion 
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 20.0 : 22.sp, // Reduced from 24sp for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 18.0 : 20.sp, // Reduced from 22sp for better proportion
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 16.0 : 18.sp, // Reduced from 20sp for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 15.0 : 16.sp, // Reduced from 18sp for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 14.0 : 15.sp, // Reduced from 16sp for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 14.0 : 16.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 12.0 : 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 10.0 : 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 14.0 : 16.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 12.0 : 14.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 10.0 : 12.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.5,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kIsWeb ? 8.0 : 8.r)),
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.0 : 16.w,
          vertical: kIsWeb ? 8.0 : 8.h,
        ),
      ),
      // Updated button styling for better visibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 2,
          textStyle: GoogleFonts.inter(
            fontSize: kIsWeb ? 14.0 : 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 16.0 : 16.w,
            vertical: kIsWeb ? 12.0 : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          textStyle: GoogleFonts.inter(
            fontSize: kIsWeb ? 14.0 : 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 16.0 : 16.w,
            vertical: kIsWeb ? 8.0 : 8.h,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
          textStyle: GoogleFonts.inter(
            fontSize: kIsWeb ? 14.0 : 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 16.0 : 16.w,
            vertical: kIsWeb ? 12.0 : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kIsWeb ? 8.0 : 8.r)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.0 : 16.w,
          vertical: kIsWeb ? 12.0 : 12.h,
        ),
        isDense: kIsWeb, // More compact inputs on web
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF4CAF50), // Green color from Faith and Grow logo
        secondary: const Color(0xFFD4AF37), // Gold color from Faith and Grow logo
        tertiary: const Color(0xFF000000), // Black color from Faith and Grow logo
        surface: const Color(0xFF15161E),
        error: const Color(0xFFFF5963),
        onPrimary: const Color(0xFFFFFFFF),
        onSecondary: const Color(0xFFE5E7EB),
        onTertiary: const Color(0xFFE5E7EB),
        onSurface: const Color(0xFFE5E7EB),
        onError: const Color(0xFFFFFFFF),
        outline: const Color(0xFF37474F),
      ),
      cardTheme: CardTheme(
        elevation: kIsWeb ? 1.0 : 4.0, // Reduced elevation for web
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kIsWeb ? 8.0 : 12.r)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(
          vertical: kIsWeb ? 8.0 : 8.h,
          horizontal: kIsWeb ? 8.0 : 8.w,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: kIsWeb ? 16.0 : 16.w,
        centerTitle: true,
        toolbarHeight: kIsWeb ? 56.0 : 56.h,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.0 : 16.w,
          vertical: kIsWeb ? 4.0 : 4.h,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: kIsWeb ? 15.0 : 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      brightness: Brightness.dark,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 42.0 : 48.sp, // Reduced for better proportion
          fontWeight: FontWeight.normal,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 34.0 : 38.sp, // Reduced for better proportion
          fontWeight: FontWeight.normal,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 28.0 : 30.sp, // Reduced for better proportion
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 24.0 : 26.sp, // Reduced for better proportion
          fontWeight: FontWeight.normal,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 20.0 : 22.sp, // Reduced for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 18.0 : 20.sp, // Reduced for better proportion
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          height: 1.3,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 16.0 : 18.sp, // Reduced for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 15.0 : 16.sp, // Reduced for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 14.0 : 15.sp, // Reduced for better proportion
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 14.0 : 16.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 12.0 : 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 10.0 : 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: kIsWeb ? 14.0 : 16.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: kIsWeb ? 12.0 : 14.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: kIsWeb ? 10.0 : 12.sp,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
          height: 1.5,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kIsWeb ? 8.0 : 8.r)),
        padding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.0 : 16.w,
          vertical: kIsWeb ? 8.0 : 8.h,
        ),
      ),
      // Updated button styling for better visibility
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 2,
          textStyle: GoogleFonts.inter(
            fontSize: kIsWeb ? 14.0 : 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 16.0 : 16.w,
            vertical: kIsWeb ? 12.0 : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          textStyle: GoogleFonts.inter(
            fontSize: kIsWeb ? 14.0 : 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 16.0 : 16.w,
            vertical: kIsWeb ? 8.0 : 8.h,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          side: const BorderSide(color: Color(0xFF4CAF50), width: 1),
          textStyle: GoogleFonts.inter(
            fontSize: kIsWeb ? 14.0 : 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: kIsWeb ? 16.0 : 16.w,
            vertical: kIsWeb ? 12.0 : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kIsWeb ? 8.0 : 8.r)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: kIsWeb ? 16.0 : 16.w,
          vertical: kIsWeb ? 12.0 : 12.h,
        ),
        isDense: kIsWeb, // More compact inputs on web
      ),
    );