import 'dart:io';

import 'package:share_plus/share_plus.dart';
import '../../routes/app_pages.dart';

/// Share utility for generating and sharing content with deep links
///
/// Follows Flutter's deep linking guidelines:
/// - Uses named routes that match AppRoutes
/// - Supports both HTTPS (App Links) and custom scheme deeplinks
/// - Includes Play Store link for app downloads
///
/// Reference: https://docs.flutter.dev/ui/navigation/deep-linking

class ShareUtil {
  // Play Store URL - Update this with your actual Play Store URL
  static String playStoreUrl = Platform.isAndroid
      ? 'https://play.google.com/store/apps/details?id=com.blf.prime'
      : 'https://apps.apple.com/us/app/blf-live/id6448539513';

  // Base deeplink URL - Update this with your actual domain
  static const String deeplinkBaseUrl = 'https://blfprime.com';
  static const String deeplinkScheme = 'blfprime';

  /// Share content with deeplink and Play Store link
  ///
  /// [contentType] - Type of content: 'movie', 'series', 'song', 'comingsoon'
  /// [contentId] - ID of the content
  /// [title] - Title of the content
  /// [description] - Optional description of the content
  static Future<void> shareContent({
    required String contentType,
    required String contentId,
    required String title,
  }) async {
    // Generate deeplink
    final deeplink = _generateDeeplink(contentType, contentId);

    // Generate Play Store link
    final playStoreLink = playStoreUrl;

    // Build share message
    final shareText = _buildShareMessage(
      title: title,
      deeplink: deeplink,
      playStoreLink: playStoreLink,
    );

    // Share the content using SharePlus
    final result = await Share.share(
      shareText,
      subject: 'Check out $title on BLF Prime',
    );
  }

  /// Generate deeplink for content
  ///
  /// According to Flutter deep linking docs, the route path should match the named route
  /// Query parameters are passed via the URL query string
  static String _generateDeeplink(String contentType, String contentId) {
    String route;
    switch (contentType.toLowerCase()) {
      case 'movie':
        route = AppRoutes.movieDetails;
        break;
      case 'series':
        route = AppRoutes.seriesDetails;
        break;
      case 'song':
        route = AppRoutes.songDetails;
        break;
      case 'comingsoon':
        route = AppRoutes.comingSoonDetails;
        break;
      default:
        route = AppRoutes.home;
    }

    // Generate HTTPS deeplink (App Links) - primary method
    // Format: https://domain.com/route?param=value
    // This follows Flutter's deep linking guidelines for App Links
    final httpsDeeplink =
        '$deeplinkBaseUrl$route?id=${Uri.encodeComponent(contentId)}';

    // Return HTTPS deeplink (App Links are preferred over custom schemes)
    // Custom scheme deeplinks can be added as fallback if needed
    return httpsDeeplink;
  }

  /// Build share message with content info, deeplink, and Play Store link
  static String _buildShareMessage({
    required String title,
    required String deeplink,
    required String playStoreLink,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('🎬 $title');
    buffer.writeln();

    buffer.writeln('📱 Watch on BLF Prime:');
    buffer.writeln(deeplink);
    buffer.writeln();

    buffer.writeln('⬇️ Download the app:');
    buffer.writeln(playStoreLink);

    return buffer.toString();
  }
}
