# Error Notification Guidelines

These guidelines ensure a consistent, user-friendly approach to error handling throughout the Faith and Grow app.

## Core Principles

1. **Contextual Placement**: Display errors at the point of action, not globally. Keep errors close to where they occurred.
2. **Non-Intrusive Display**: Use non-blocking notifications that don't disrupt user workflow.
3. **Clear Language**: Write messages in plain language that explains what happened and what to do next.
4. **Actionable Solutions**: Always provide a clear next step or suggestion when possible.
5. **Visual Consistency**: Use consistent styling for all error types across the app.

## Types of Error Notifications

1. **Toast Notifications**:
   - Use for temporary, non-critical errors
   - Auto-dismiss after 5 seconds
   - Can include an action button for immediate response
   - Example: "Image upload failed: Please try a smaller image."

2. **Inline Notifications**:
   - Use for form validation and field-specific errors
   - Display directly beneath the relevant input field
   - Remain visible until the error is corrected
   - Example: "Please enter a valid email address."

3. **Banner Notifications**:
   - Use for page or section-level errors
   - Display at the top of content area, not fixed to screen
   - Include a dismiss button
   - Example: "Couldn't load your communities. Please check your connection."

4. **Dialog Notifications**:
   - Use only for critical errors that prevent proceeding
   - Block interaction with the page until acknowledged
   - Include clear action buttons
   - Example: "Your subscription has expired. Please renew to continue."

## Message Structure

1. **Title (optional)**: Brief identifier of the issue type
2. **Description (required)**: Clear explanation of what happened
3. **Action (required)**: What the user can or should do next
4. **Support Reference (optional)**: For persistent issues, include contact info

## Error Message Guidelines

1. **Be specific**: "Image upload failed: File size exceeds 5MB" rather than "Upload error".
2. **Be constructive**: Focus on solutions, not problems.
3. **Avoid blame**: Use "We couldn't process your request" instead of "You entered invalid data".
4. **Avoid technical jargon**: "Connection lost" instead of "HTTP 503 error".
5. **Be consistent**: Use the same terminology throughout the app.

## Visual Style

1. **Error (Red)**: For actions that failed or require immediate attention.
2. **Warning (Amber/Yellow)**: For potential issues or required attention.
3. **Info (Blue)**: For neutral information.
4. **Success (Green)**: For confirmation of completed actions.

## Implementation Examples

### Toast Notification Example
```dart
ErrorNotification.showToast(
  context: context,
  message: 'Failed to upload image. Please try a smaller file size.',
  type: NotificationType.error,
  actionLabel: 'Try Again',
  onAction: () => _retryUpload(),
);
```

### Banner Notification Example
```dart
ErrorNotification.banner(
  message: 'We couldn\'t connect to the server. Please check your internet connection.',
  context: context,
  type: NotificationType.warning,
  onAction: () => _retryConnection(),
  actionLabel: 'Retry',
);
```

### Inline Error Example
```dart
ErrorNotification.inline(
  message: 'Please enter a valid email address',
  context: context,
  type: NotificationType.error,
);
```