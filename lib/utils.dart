import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for date formatting and manipulation
class DateUtils {
  /// Format date as 'MMM dd, yyyy' (e.g., 'Jan 15, 2024')
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date as 'dd/MM/yyyy'
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date and time as 'MMM dd, yyyy - HH:mm'
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  /// Format time as 'HH:mm'
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Get day name (e.g., 'Monday')
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get short day name (e.g., 'Mon')
  static String getShortDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday 00:00:00)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = (date.weekday - DateTime.monday) % 7;
    final monday = date.subtract(Duration(days: daysFromMonday));
    return startOfDay(monday);
  }

  /// Get end of week (Sunday 23:59:59)
  static DateTime endOfWeek(DateTime date) {
    final start = startOfWeek(date);
    final sunday = start.add(const Duration(days: 6));
    return endOfDay(sunday);
  }

  /// Get list of dates for the last N days
  static List<DateTime> getLastNDays(int n) {
    final now = DateTime.now();
    return List.generate(
      n,
      (index) => startOfDay(now.subtract(Duration(days: n - 1 - index))),
    );
  }

  /// Get relative date string (e.g., 'Today', 'Yesterday', 'Tomorrow')
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final dateOnly = startOfDay(date);

    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1 && difference <= 7) {
      return 'In ${getDayName(date)}';
    }
    if (difference < -1 && difference >= -7) {
      return getDayName(date);
    }

    return formatDate(date);
  }
}

/// Utility class for color operations
class ColorUtils {
  /// Get color from category color list by index
  static Color getCategoryColor(int index, List<Color> colors) {
    if (colors.isEmpty) return Colors.grey;
    return colors[index % colors.length];
  }

  /// Convert Color to int for storage
  static int colorToInt(Color color) {
    return color.value;
  }

  /// Convert int to Color
  static Color intToColor(int colorValue) {
    return Color(colorValue);
  }

  /// Generate a contrasting text color (black or white) based on background
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance
    final luminance = backgroundColor.computeLuminance();

    // Use white text for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// Utility class for validation
class ValidationUtils {
  /// Validate task title
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  /// Validate category name
  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category name cannot be empty';
    }
    if (value.trim().length < 2) {
      return 'Category name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Category name must be less than 30 characters';
    }
    return null;
  }

  /// Validate description (optional, but if provided must meet criteria)
  static String? validateDescription(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length > 500) {
        return 'Description must be less than 500 characters';
      }
    }
    return null;
  }
}

/// Utility class for statistics calculations
class StatsUtils {
  /// Calculate completion rate (0.0 to 1.0)
  static double calculateCompletionRate(int completed, int total) {
    if (total == 0) return 0.0;
    return completed / total;
  }

  /// Calculate completion percentage (0 to 100)
  static int calculateCompletionPercentage(int completed, int total) {
    return (calculateCompletionRate(completed, total) * 100).round();
  }

  /// Format percentage as string
  static String formatPercentage(double rate) {
    return '${(rate * 100).toStringAsFixed(0)}%';
  }
}

/// Extension on IconData for serialization
extension IconDataExtension on IconData {
  /// Convert IconData to int for storage
  int toInt() {
    return codePoint;
  }

  /// Create IconData from int
  static IconData fromInt(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
