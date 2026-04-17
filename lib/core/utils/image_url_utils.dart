/// Image URL Utility for AgriFlow
/// Converts various image URL formats to direct, accessible URLs
/// Supports: Google Drive, Direct URLs, and other cloud storage services
library;

class ImageUrlUtils {
  /// Convert Google Drive sharing URL to direct image URL
  /// Input formats supported:
  /// - https://drive.google.com/file/d/FILE_ID/view
  /// - https://drive.google.com/open?id=FILE_ID
  /// - https://drive.google.com/uc?id=FILE_ID
  /// - https://docs.google.com/uc?id=FILE_ID
  static String? convertGoogleDriveUrl(String url) {
    if (url.isEmpty) return null;

    // Google Drive file URL pattern
    final driveFileRegex =
        RegExp(r'https?://drive\.google\.com/file/d/([^/]+)/');
    final driveIdRegex = RegExp(r'id=([^&]+)');

    // Check if it's a Google Drive URL
    if (!url.contains('drive.google.com') &&
        !url.contains('docs.google.com')) {
      return null;
    }

    // Extract file ID from /file/d/ID/ format
    final fileMatch = driveFileRegex.firstMatch(url);
    if (fileMatch != null) {
      final fileId = fileMatch.group(1);
      if (fileId != null) {
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    // Extract file ID from ?id=ID format
    final idMatch = driveIdRegex.firstMatch(url);
    if (idMatch != null) {
      final fileId = idMatch.group(1);
      if (fileId != null) {
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    // Already a direct URL
    if (url.contains('uc?export=view') || url.contains('uc?id=')) {
      return url;
    }

    return null;
  }

  /// Convert Dropbox sharing URL to direct image URL
  static String? convertDropboxUrl(String url) {
    if (url.isEmpty) return null;

    if (!url.contains('dropbox.com')) return null;

    // Convert dl.dropboxusercontent.com or www.dropbox.com to direct URL
    if (url.contains('dl=0') || url.contains('dl=1')) {
      // Replace dl=0 with dl=1 for direct download
      return url.replaceAll('dl=0', 'dl=1');
    }

    // Convert www.dropbox.com to dl.dropboxusercontent.com
    if (url.contains('www.dropbox.com')) {
      return '${url
          .replaceFirst('www.dropbox.com', 'dl.dropboxusercontent.com')}?dl=1';
    }

    return url;
  }

  /// Convert OneDrive sharing URL to direct image URL
  static String? convertOneDriveUrl(String url) {
    if (url.isEmpty) return null;

    if (!url.contains('1drv.ms') && !url.contains('onedrive.live.com')) {
      return null;
    }

    // OneDrive embed URLs can be used directly
    if (url.contains('embed.aspx')) {
      return url;
    }

    // For regular sharing links, user needs to get embed link
    // We'll return the original URL for now
    return url;
  }

  /// Detect if URL is a valid image URL
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    // Must be a valid URL
    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) return false;
    } catch (e) {
      return false;
    }

    // Check for image extensions
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.svg',
      '.bmp',
      '.tiff',
      '.ico',
    ];

    final urlLower = url.toLowerCase();
    for (final ext in imageExtensions) {
      if (urlLower.contains(ext)) return true;
    }

    // Google Drive and other cloud storage URLs are valid
    if (url.contains('drive.google.com') ||
        url.contains('docs.google.com') ||
        url.contains('dropbox.com') ||
        url.contains('1drv.ms') ||
        url.contains('onedrive.live.com')) {
      return true;
    }

    return true; // Allow any HTTP URL - the image loader will handle validation
  }

  /// Normalize any image URL to a direct, usable format
  static String normalizeImageUrl(String url) {
    if (url.isEmpty) return '';

    url = url.trim();

    // Try Google Drive conversion
    final googleDriveUrl = convertGoogleDriveUrl(url);
    if (googleDriveUrl != null) return googleDriveUrl;

    // Try Dropbox conversion
    final dropboxUrl = convertDropboxUrl(url);
    if (dropboxUrl != null) return dropboxUrl;

    // Try OneDrive conversion
    final oneDriveUrl = convertOneDriveUrl(url);
    if (oneDriveUrl != null) return oneDriveUrl;

    // Return original URL if no conversion needed
    return url;
  }

  /// Get display URL for UI (shows user-friendly format)
  static String getDisplayUrl(String url) {
    if (url.isEmpty) return '';

    // If it's a Google Drive direct URL, show the original sharing URL format
    if (url.contains('drive.google.com/uc?')) {
      final idMatch = RegExp(r'id=([^&]+)').firstMatch(url);
      if (idMatch != null) {
        final fileId = idMatch.group(1);
        if (fileId != null) {
          return 'https://drive.google.com/file/d/$fileId/view';
        }
      }
    }

    return url;
  }

  /// Get placeholder text for image URL input
  static String getPlaceholderText() {
    return 'Paste image URL (Google Drive, Dropbox, or direct link)';
  }

  /// Get help text for image URL input
  static String getHelpText() {
    return 'Supported: Google Drive, Dropbox, direct image URLs (.jpg, .png, etc.)';
  }
}
