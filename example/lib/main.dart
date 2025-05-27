import 'package:animated_notification/animated_notification.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'This is an info notification!',
                  type: NotificationType.info,
                );
              },
              child: const Text('Show Info Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'Success! Your operation was completed.',
                  type: NotificationType.success,
                  icon: const Icon(Icons.check_circle_outline),
                );
              },
              child: const Text('Show Success Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'Warning: Something might be wrong.',
                  type: NotificationType.warning,
                  actionLabel: 'Details',
                  onActionPressed: () {
                    // ignore: avoid_print
                    print('Details button pressed!');
                    NotificationService().dismiss();
                  },
                );
              },
              child: const Text('Show Warning Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'Error: Failed to load data.',
                  type: NotificationType.error,
                  duration: const Duration(seconds: 5),
                  showProgressBar: true,
                  dismissible: true,
                );
              },
              child: const Text('Show Error Notification'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NotificationService().show(
                  context,
                  message: 'This notification will not dismiss automatically.',
                  type: NotificationType.info,
                  duration: Duration
                      .zero, // Notification stays until dismissed manually
                  dismissible: true,
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animated Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainApp(),
    );
  }
}
