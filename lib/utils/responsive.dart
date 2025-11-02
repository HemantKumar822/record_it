import 'package:flutter/cupertino.dart';

/// Responsive utility class for adaptive sizing across different screen sizes
class Responsive {
  final BuildContext context;
  
  Responsive(this.context);
  
  /// Get screen width
  double get width => MediaQuery.of(context).size.width;
  
  /// Get screen height
  double get height => MediaQuery.of(context).size.height;
  
  /// Get responsive width based on design width (375px base - iPhone size)
  double wp(double percentage) => width * percentage / 100;
  
  /// Get responsive height based on design height
  double hp(double percentage) => height * percentage / 100;
  
  /// Get responsive font size
  double sp(double size) {
    // Base width is 375 (iPhone standard)
    double scaleFactor = width / 375;
    // Clamp the scale factor to avoid too large or too small text
    scaleFactor = scaleFactor.clamp(0.8, 1.3);
    return size * scaleFactor;
  }
  
  /// Get responsive padding/margin
  double spacing(double size) {
    double scaleFactor = width / 375;
    scaleFactor = scaleFactor.clamp(0.85, 1.2);
    return size * scaleFactor;
  }
  
  /// Check if device is small (< 360px width)
  bool get isSmallDevice => width < 360;
  
  /// Check if device is medium (360-414px width)
  bool get isMediumDevice => width >= 360 && width < 414;
  
  /// Check if device is large (>= 414px width)
  bool get isLargeDevice => width >= 414;
  
  /// Get icon size based on device
  double iconSize(double baseSize) {
    if (isSmallDevice) return baseSize * 0.9;
    if (isLargeDevice) return baseSize * 1.1;
    return baseSize;
  }
  
  /// Get button size based on device
  double buttonSize(double baseSize) {
    if (isSmallDevice) return baseSize * 0.95;
    if (isLargeDevice) return baseSize * 1.05;
    return baseSize;
  }
}

/// Extension on BuildContext for easy access to responsive values
extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive(this);
  
  /// Quick access to responsive width percentage
  double wp(double percentage) => Responsive(this).wp(percentage);
  
  /// Quick access to responsive height percentage
  double hp(double percentage) => Responsive(this).hp(percentage);
  
  /// Quick access to responsive font size
  double sp(double size) => Responsive(this).sp(size);
  
  /// Quick access to responsive spacing
  double spacing(double size) => Responsive(this).spacing(size);
}

/// App-wide spacing constants (used with spacing() method)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

/// App-wide font size constants (used with sp() method)
class AppFontSize {
  static const double caption = 12.0;
  static const double body = 15.0;
  static const double bodyLarge = 16.0;
  static const double subtitle = 17.0;
  static const double title = 20.0;
  static const double heading = 28.0;
  static const double display = 38.0;
}

/// App-wide icon size constants (used with iconSize() method)
class AppIconSize {
  static const double xs = 14.0;
  static const double sm = 18.0;
  static const double md = 20.0;
  static const double lg = 22.0;
  static const double xl = 32.0;
  static const double xxl = 44.0;
}
