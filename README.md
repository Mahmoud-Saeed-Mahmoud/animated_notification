# Animated Notification

A customizable Flutter package for displaying animated, dismissible in-app notifications.

## Features

- **Customizable:** Easily change message, duration, type (info, success, warning, error), icon, and more.
- **Animated:** Smooth slide, fade, and scale animations for a modern look.
- **Dismissible:** Users can dismiss notifications manually or they can auto-dismiss after a set duration.
- **Actionable:** Include an optional action button with a custom label and callback.
- **Progress Bar:** Display a linear progress bar indicating the remaining display time.
- **Singleton Service:** A `NotificationService` singleton ensures only one notification is shown at a time, managing the overlay.

## Getting started

1. Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  animated_notification:
    git:
      url: https://github.com/Mahmoud-Saeed-Mahmoud/animated_notification.git
      ref: main # Or the branch/tag you want to use
```

2. Run `flutter pub get`.

## Usage

Import the package:

```dart
import 'package:animated_notification/animated_notification.dart';
```

To show a notification, use the `NotificationService` singleton:

```dart
NotificationService().show(
  context,
  message: 'This is an info notification!',
  type: NotificationType.info,
  duration: const Duration(seconds: 3), // Optional: defaults to 3 seconds
  onTap: () {
    // Optional: callback when notification is tapped
    print('Notification tapped!');
  },
  icon: const Icon(Icons.info_outline), // Optional: custom icon
  showProgressBar: true, // Optional: defaults to true
  actionLabel: 'View',
  onActionPressed: () {
    // Optional: callback for action button
    print('Action button pressed!');
  },
  dismissible: true, // Optional: defaults to true
);
```

To dismiss the current notification manually:

```dart
NotificationService().dismiss();
```

For more detailed examples, refer to the `/example` folder in the repository.

## Demo

<video src="preview.mp4" width="320" controls></video>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
