/// Utility class for formatting duration from seconds to readable format
/// 
/// Formats duration as:
/// - "1hr 30min" for durations with hours
/// - "40min" for durations less than 1 hour
/// - "HH:MM" format as alternative
class DurationFormatter {
  /// Format duration from seconds (int or string) to readable format
  /// 
  /// [duration] - Duration in seconds (can be int, string number, or already formatted)
  /// [format] - Format type: 'readable' (1hr 30min) or 'time' (HH:MM)
  /// 
  /// Returns formatted string like "1hr 30min" or "40min" or "01:30"
  static String formatDuration(String duration, {String format = 'readable'}) {
    if (duration.isEmpty) return '';
    
    // Try to parse as integer (seconds)
    final seconds = int.tryParse(duration.trim());
    
    // If not a number, assume it's already formatted and return as is
    if (seconds == null) {
      return duration;
    }
    
    // Format based on requested format
    if (format == 'time') {
      return _formatAsTime(seconds);
    } else {
      return _formatAsReadable(seconds);
    }
  }
  
  /// Format duration as readable text (1hr 30min, 40min)
  static String _formatAsReadable(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}hr ${minutes}min';
      } else {
        return '${hours}hr';
      }
    } else {
      return '${minutes}min';
    }
  }
  
  /// Format duration as time (HH:MM)
  static String _formatAsTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } else {
      return '00:${minutes.toString().padLeft(2, '0')}';
    }
  }
  
  /// Format duration from int seconds directly
  static String formatFromSeconds(int seconds, {String format = 'readable'}) {
    if (format == 'time') {
      return _formatAsTime(seconds);
    } else {
      return _formatAsReadable(seconds);
    }
  }
}

