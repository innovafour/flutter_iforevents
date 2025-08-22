/// Configuration for the event retry system
class RetryConfig {
  /// Default retry intervals (in seconds)
  /// First retry: 30 seconds
  /// Second retry: 2 minutes (120 seconds)
  /// Third retry: 5 minutes (300 seconds)
  static const List<int> defaultRetryIntervals = [30, 120, 300];

  /// Maximum number of attempts per event
  static const int maxRetryAttempts = 3;

  /// Default interval for background processing (in seconds)
  static const int defaultBackgroundProcessingInterval = 30;

  /// Minimum time between retries (in seconds)
  static const int minimumRetryInterval = 10;

  /// Maximum time between retries (in seconds)
  static const int maximumRetryInterval = 3600; // 1 hour

  /// Current retry intervals configuration
  static List<int> _currentRetryIntervals = List.from(defaultRetryIntervals);

  /// Current background processing interval configuration
  static int _currentBackgroundInterval = defaultBackgroundProcessingInterval;

  /// Gets the current retry intervals
  static List<int> get retryIntervals => List.from(_currentRetryIntervals);

  /// Gets the current background processing interval
  static int get backgroundProcessingInterval => _currentBackgroundInterval;

  /// Configures custom retry intervals
  ///
  /// [intervals] must contain exactly 3 values in seconds
  /// Each value must be between [minimumRetryInterval] and [maximumRetryInterval]
  static bool setRetryIntervals(List<int> intervals) {
    if (intervals.length != maxRetryAttempts) {
      return false;
    }

    // Validate that all intervals are within the allowed range
    for (final interval in intervals) {
      if (interval < minimumRetryInterval || interval > maximumRetryInterval) {
        return false;
      }
    }

    _currentRetryIntervals = List.from(intervals);
    return true;
  }

  /// Configures the background processing interval
  ///
  /// [intervalSeconds] must be between [minimumRetryInterval] and [maximumRetryInterval]
  static bool setBackgroundProcessingInterval(int intervalSeconds) {
    if (intervalSeconds < minimumRetryInterval ||
        intervalSeconds > maximumRetryInterval) {
      return false;
    }

    _currentBackgroundInterval = intervalSeconds;
    return true;
  }

  /// Restores the default configuration
  static void resetToDefaults() {
    _currentRetryIntervals = List.from(defaultRetryIntervals);
    _currentBackgroundInterval = defaultBackgroundProcessingInterval;
  }

  /// Gets the retry interval for a specific attempt
  ///
  /// [attemptNumber] must be between 1 and [maxRetryAttempts]
  /// Returns null if the attempt number is invalid
  static int? getRetryIntervalForAttempt(int attemptNumber) {
    if (attemptNumber < 1 || attemptNumber > maxRetryAttempts) {
      return null;
    }

    return _currentRetryIntervals[attemptNumber - 1];
  }

  /// Validates if a set of intervals is valid
  static bool validateRetryIntervals(List<int> intervals) {
    if (intervals.length != maxRetryAttempts) {
      return false;
    }

    for (final interval in intervals) {
      if (interval < minimumRetryInterval || interval > maximumRetryInterval) {
        return false;
      }
    }

    return true;
  }

  /// Validates if a background processing interval is valid
  static bool validateBackgroundInterval(int intervalSeconds) {
    return intervalSeconds >= minimumRetryInterval &&
        intervalSeconds <= maximumRetryInterval;
  }

  /// Gets the current configuration as a map
  static Map<String, dynamic> toMap() {
    return {
      'retryIntervals': _currentRetryIntervals,
      'backgroundProcessingInterval': _currentBackgroundInterval,
      'maxRetryAttempts': maxRetryAttempts,
      'minimumRetryInterval': minimumRetryInterval,
      'maximumRetryInterval': maximumRetryInterval,
    };
  }

  /// Loads configuration from a map
  static bool fromMap(Map<String, dynamic> config) {
    try {
      final intervals = List<int>.from(
        config['retryIntervals'] ?? defaultRetryIntervals,
      );
      final backgroundInterval =
          config['backgroundProcessingInterval'] ??
          defaultBackgroundProcessingInterval;

      if (validateRetryIntervals(intervals) &&
          validateBackgroundInterval(backgroundInterval)) {
        _currentRetryIntervals = intervals;
        _currentBackgroundInterval = backgroundInterval;
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Predefined configurations for different scenarios
  static const Map<String, List<int>> presetConfigurations = {
    'aggressive': [10, 30, 60], // Fast retries
    'balanced': [30, 120, 300], // Default configuration
    'conservative': [60, 300, 900], // More spaced retries
    'patient': [120, 600, 1800], // Very spaced retries
  };

  /// Applies a predefined configuration
  static bool applyPresetConfiguration(String presetName) {
    final preset = presetConfigurations[presetName];
    if (preset != null) {
      return setRetryIntervals(preset);
    }
    return false;
  }

  /// Gets the names of available predefined configurations
  static List<String> get availablePresets =>
      presetConfigurations.keys.toList();
}
