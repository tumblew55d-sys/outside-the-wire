import 'package:flutter/material.dart';

/// Utility class for responsive design
/// Detects device type and provides adaptive sizing
class ResponsiveUtils {
  /// Breakpoints for device types
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  /// Check if device is a phone
  static bool isPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < phoneMaxWidth;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  /// Check if device is a desktop/large screen
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }

  /// Get responsive padding based on device type
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isPhone(context)) {
      return const EdgeInsets.all(12.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get responsive card padding
  static EdgeInsets getCardPadding(BuildContext context) {
    if (isPhone(context)) {
      return const EdgeInsets.all(8.0);
    } else {
      return const EdgeInsets.all(12.0);
    }
  }

  /// Get responsive font size for titles
  static double getTitleFontSize(BuildContext context) {
    if (isPhone(context)) {
      return 18.0;
    } else if (isTablet(context)) {
      return 22.0;
    } else {
      return 24.0;
    }
  }

  /// Get responsive font size for body text
  static double getBodyFontSize(BuildContext context) {
    if (isPhone(context)) {
      return 14.0;
    } else {
      return 16.0;
    }
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context) {
    if (isPhone(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  /// Get responsive column count for grids
  static int getGridCrossAxisCount(BuildContext context) {
    if (isPhone(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get max content width for centering on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200;
    }
    return double.infinity;
  }

  /// Wrap content with max width constraint for desktop
  static Widget constrainWidth(BuildContext context, Widget child) {
    if (isDesktop(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: getMaxContentWidth(context)),
          child: child,
        ),
      );
    }
    return child;
  }

  /// Get device type as string (for debugging/logging)
  static String getDeviceType(BuildContext context) {
    if (isPhone(context)) return 'Phone';
    if (isTablet(context)) return 'Tablet';
    return 'Desktop';
  }

  /// Get responsive dashboard roster flex
  static int getDashboardRosterFlex(BuildContext context) {
    if (isPhone(context)) {
      return 1; // Full width on phone
    } else {
      return 4; // 40% on tablet/desktop
    }
  }

  /// Get responsive dashboard actions flex
  static int getDashboardActionsFlex(BuildContext context) {
    if (isPhone(context)) {
      return 1; // Full width on phone
    } else {
      return 6; // 60% on tablet/desktop
    }
  }

  /// Check if should use compact layout
  static bool useCompactLayout(BuildContext context) {
    return isPhone(context);
  }

  /// Get button height based on device
  static double getButtonHeight(BuildContext context) {
    if (isPhone(context)) {
      return 48.0;
    } else {
      return 54.0;
    }
  }

  /// Get icon size based on device
  static double getIconSize(BuildContext context) {
    if (isPhone(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }
}
