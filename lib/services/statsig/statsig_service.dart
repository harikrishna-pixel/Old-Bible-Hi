import 'package:statsig/statsig.dart';

class StatsigService {
  static const String _clientKey = 'client-fmtOxhVkeDEKoy76xLj3eI3X2stWUm1sUpppi6UQWEB';
  static bool _isInitialized = false;

  /// Initialize Statsig SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Statsig with client key
      await Statsig.initialize(_clientKey);
      _isInitialized = true;
    } catch (e) {
      // Silently handle initialization errors
      print('Statsig initialization error: $e');
    }
  }

  /// Track event for Home Screen
  static void trackHomeScreen() {
    _trackEvent('home_screen');
  }

  /// Track event for Geneva Bible Chat
  static void trackGenevaBibleChat() {
    _trackEvent('geneva_bible_chat');
  }

  /// Track event for Daily Verses
  static void trackDailyVerses() {
    _trackEvent('daily_verses');
  }

  /// Track event for Wallpaper
  static void trackWallpaper() {
    _trackEvent('wallpaper');
  }

  /// Track event for Quotes
  static void trackQuotes() {
    _trackEvent('quotes');
  }

  /// Track event for Books
  static void trackBooks() {
    _trackEvent('books');
  }

  /// Track event for Share
  static void trackShare() {
    _trackEvent('share');
  }

  /// Track event for Paywall Screen
  static void trackPaywallScreen() {
    _trackEvent('paywall_screen');
  }

  /// Internal method to track events
  static void _trackEvent(String eventName) {
    if (!_isInitialized) return;
    
    try {
      Statsig.logEvent(eventName);
    } catch (e) {
      // Silently handle tracking errors
      print('Statsig tracking error: $e');
    }
  }
}

