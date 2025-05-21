/// A utility class for generating user-friendly error messages.
/// This helps create consistent, clear, and actionable error messages
/// throughout the application.
class ErrorMessages {
  /// Returns a user-friendly message for community publishing errors
  static String getPublishingErrorMessage(String error) {
    if (error.contains('permission-denied') || error.contains('insufficient permissions')) {
      return 'You don\'t have permission to publish this community. Please verify your account has the necessary privileges.';
    } else if (error.contains('not-found')) {
      return 'We couldn\'t find this community in our database. It may have been deleted.';
    } else if (error.contains('network')) {
      return 'Unable to connect to our servers. Please check your internet connection and try again.';
    } else if (error.contains('already-exists')) {
      return 'This community has already been published.';
    } else if (error.contains('resource-exhausted')) {
      return 'You\'ve reached the limit for community creation with your current subscription plan.';
    } else if (error.contains('cancelled')) {
      return 'Operation was cancelled. Please try again.';
    } else {
      return 'We encountered an unexpected error while publishing your community. Please try again later. Support reference: ${getSupportReferenceCode(error)}';
    }
  }

  /// Returns a user-friendly message for community creation errors
  static String getCreationErrorMessage(String error) {
    if (error.contains('permission-denied') || error.contains('insufficient permissions')) {
      return 'You don\'t have permission to create a community. This could be related to your subscription tier or account status. Try enabling Developer Mode in Settings to bypass this restriction.';
    } else if (error.contains('network')) {
      return 'Unable to connect to our servers. Please check your internet connection and try again.';
    } else if (error.contains('already-exists')) {
      return 'A community with this name already exists. Please choose a different name.';
    } else if (error.contains('resource-exhausted')) {
      return 'You\'ve reached the limit for community creation with your current subscription plan.';
    } else if (error.contains('invalid-argument')) {
      return 'Some information provided is invalid. Please check all fields and try again.';
    } else if (error.contains('cancelled')) {
      return 'Operation was cancelled. Please try again.';
    } else if (error.contains('quota-exceeded')) {
      return 'You\'ve reached your limit for community creation. Please upgrade your plan for more communities.';
    } else {
      return 'We encountered an unexpected error while creating your community. Please try again later. Support reference: ${getSupportReferenceCode(error)}';
    }
  }

  /// Returns a support reference code from a technical error
  static String getSupportReferenceCode(String error) {
    String errorClean = error.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return errorClean.substring(0, min(errorClean.length, 8)).toUpperCase();
  }
  
  /// Returns a user-friendly action suggestion based on the error
  static String getActionSuggestion(String error) {
    if (error.contains('permission-denied')) {
      return 'Try enabling Developer Mode in the Settings menu, then try again.';
    } else if (error.contains('network')) {
      return 'Check your internet connection and try again.';
    } else {
      return 'Try again, or contact support if the issue persists.';
    }
  }
  
  /// Returns a support message for community publishing errors
  static String getSupportMessage() {
    return 'If this problem persists, please contact our support team.';
  }
  
  /// Extracts an error code from a technical error message
  static String _extractErrorCode(String error) {
    final RegExp codeRegExp = RegExp(r'\[(.*?)\]');
    final match = codeRegExp.firstMatch(error);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? 'unknown';
    }
    return 'unknown';
  }
  
  /// Helper function to get minimum of two integers
  static int min(int a, int b) => a < b ? a : b;
}