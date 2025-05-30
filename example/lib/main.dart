/// This example demonstrates various types of animated notifications using the
/// animated_notification package. It showcases different notification types,
/// customization options, and interaction patterns.
library;

import 'package:animated_notification/animated_notification.dart';
import 'package:flutter/material.dart';

/// Entry point of the application
void main() {
  runApp(const MyApp());
}

/// Main content widget that displays various notification examples
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Notification Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Basic info notification example
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'This is an info notification!',
                  type: NotificationType.info, // Uses the default info styling
                );
              },
              child: const Text('Show Info Notification'),
            ),
            const SizedBox(height: 16),

            // Success notification with custom icon
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'Success! Your operation was completed.',
                  type: NotificationType.success,
                  icon: const Icon(
                      Icons.check_circle_outline), // Custom success icon
                );
              },
              child: const Text('Show Success Notification'),
            ),
            const SizedBox(height: 16),

            // Warning notification with action button
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'Warning: Something might be wrong.',
                  type: NotificationType.warning,
                  actionLabel: 'Details', // Adds an action button
                  onActionPressed: () {
                    // Callback when action button is pressed
                    // ignore: avoid_print
                    print('Details button pressed!');
                    NotificationService().dismiss();
                  },
                );
              },
              child: const Text('Show Warning Notification'),
            ),
            const SizedBox(height: 16),

            // Error notification with progress bar
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'Error: Failed to load data.',
                  type: NotificationType.error,
                  duration: const Duration(seconds: 5), // Custom duration
                  showProgressBar: true, // Shows a progress indicator
                  dismissible: true, // Can be dismissed by user
                );
              },
              child: const Text('Show Error Notification'),
            ),
            const SizedBox(height: 16),

            // Persistent notification example
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'This notification will not dismiss automatically.',
                  type: NotificationType.info,
                  duration: Duration
                      .zero, // Notification stays until dismissed manually
                  dismissible: true, // Allows manual dismissal
                );
              },
              child: const Text('Show Persistent Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Root widget of the application
/// Configures the overall app theme and structure
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      title: 'Animated Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sets the primary color theme
      ),
      home: const MainApp(), // Sets the home screen
    );
  }
}
