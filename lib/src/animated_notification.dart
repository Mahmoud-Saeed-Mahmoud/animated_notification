import 'dart:async';

import 'package:flutter/foundation.dart'
    show
        DiagnosticPropertiesBuilder,
        DiagnosticsProperty,
        ObjectFlagProperty,
        EnumProperty;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show StringProperty;

/// A widget that displays an animated notification message with various customization options.
///
/// The notification appears with a sliding animation from the top of the screen and can include:
/// - A custom message
/// - An icon (default or custom)
/// - A progress bar showing the remaining time
/// - An action button
/// - A dismiss button
///
/// The notification can be dismissed by:
/// - Tapping on it (if [onTap] is not provided)
/// - Swiping horizontally
/// - Tapping the close button (if [dismissible] is true)
/// - Automatically after [duration] (if not set to Duration.zero)
class AnimatedNotification extends StatefulWidget {
  /// Creates an animated notification widget.
  ///
  /// The [message] parameter is required and specifies the text to display.
  /// [duration] defaults to 3 seconds and controls how long the notification is shown.
  /// [type] determines the color scheme and default icon (defaults to info).
  /// [showProgressBar] controls the visibility of the progress indicator.
  /// [dismissible] determines if the notification can be manually dismissed.
  const AnimatedNotification({
    required this.message,
    super.key,
    this.duration = const Duration(seconds: 3),
    this.type = NotificationType.info,
    this.onTap,
    this.icon,
    this.showProgressBar = true,
    this.actionLabel,
    this.onActionPressed,
    this.dismissible = true,
  });

  /// The message text to display in the notification
  final String message;

  /// How long the notification should remain visible
  final Duration duration;

  /// The type of notification which determines its color and icon
  final NotificationType type;

  /// Callback function when the notification is tapped
  final VoidCallback? onTap;

  /// Custom icon widget to override the default icon
  final Widget? icon;

  /// Whether to show the progress bar indicating remaining time
  final bool showProgressBar;

  /// Label text for the action button
  final String? actionLabel;

  /// Callback function when the action button is pressed
  final VoidCallback? onActionPressed;

  /// Whether the notification can be dismissed manually
  final bool dismissible;

  @override
  State<AnimatedNotification> createState() => _AnimatedNotificationState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('message', message))
      ..add(DiagnosticsProperty<Duration>('duration', duration))
      ..add(EnumProperty<NotificationType>('type', type))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(DiagnosticsProperty<bool>('showProgressBar', showProgressBar))
      ..add(StringProperty('actionLabel', actionLabel))
      ..add(ObjectFlagProperty<VoidCallback?>.has(
          'onActionPressed', onActionPressed))
      ..add(DiagnosticsProperty<bool>('dismissible', dismissible));
  }
}

/// A singleton service class that manages the display of notifications.
///
/// This service ensures only one notification is shown at a time and handles
/// the proper cleanup of previous notifications before showing new ones.
class NotificationService {
  /// Factory constructor that returns the singleton instance
  factory NotificationService() => _instance;

  /// Private constructor for singleton pattern
  NotificationService._internal();

  /// Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  /// Current overlay entry for the active notification
  OverlayEntry? _currentEntry;

  /// Timer that controls automatic dismissal
  Timer? _timer;

  /// Dismisses the currently showing notification if any
  void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
    _timer?.cancel();
    _timer = null;
  }

  /// Shows a new notification with the specified parameters
  ///
  /// If a notification is already showing, it will be dismissed first.
  /// The notification will be positioned at the top of the screen with proper
  /// safe area padding.
  void show(
    final BuildContext context, {
    required final String message,
    final NotificationType type = NotificationType.info,
    final Duration duration = const Duration(seconds: 3),
    final VoidCallback? onTap,
    final Widget? icon,
    final bool showProgressBar = true,
    final String? actionLabel,
    final VoidCallback? onActionPressed,
    final bool dismissible = true,
  }) {
    // Remove existing notification if any
    _currentEntry?.remove();
    _timer?.cancel();

    final OverlayState overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (final context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: AnimatedNotification(
          message: message,
          type: type,
          duration: duration,
          onTap: onTap,
          icon: icon,
          showProgressBar: showProgressBar,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
          dismissible: dismissible,
        ),
      ),
    );

    overlay.insert(_currentEntry!);

    // Set up auto-dismiss timer if duration is not zero
    if (duration != Duration.zero) {
      _timer = Timer(duration + const Duration(milliseconds: 600), () {
        _currentEntry?.remove();
        _currentEntry = null;
      });
    }
  }
}

/// Defines the different types of notifications available
///
/// Each type has its own color scheme and default icon
enum NotificationType {
  /// Green color scheme with checkmark icon
  success,

  /// Red color scheme with error icon
  error,

  /// Orange color scheme with warning icon
  warning,

  /// Blue color scheme with info icon
  info
}

class _AnimatedNotificationState extends State<AnimatedNotification>
    with SingleTickerProviderStateMixin {
  /// Controller for all animations
  late AnimationController _controller;

  /// Controls the sliding entrance animation
  late Animation<Offset> _slideAnimation;

  /// Controls the fade in/out animation
  late Animation<double> _fadeAnimation;

  /// Controls the progress bar animation
  late Animation<double> _progressAnimation;

  /// Controls the scale animation
  late Animation<double> _scaleAnimation;

  /// Controls the icon rotation animation
  late Animation<double> _iconRotationAnimation;

  @override
  Widget build(final BuildContext context) => SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: widget.onTap ?? _dismiss,
                onHorizontalDragEnd: (final _) => _dismiss(),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                AnimatedBuilder(
                                  animation: _iconRotationAnimation,
                                  builder: (final context, final child) =>
                                      Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..rotateZ(_iconRotationAnimation.value *
                                          2 *
                                          3.141592653589793),
                                    child: widget.icon ??
                                        Icon(
                                          _getDefaultIcon(),
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.message,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (widget.actionLabel != null) ...[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: widget.onActionPressed,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(widget.actionLabel!),
                                  ),
                                ],
                                if (widget.dismissible) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white),
                                    onPressed: _dismiss,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.showProgressBar &&
                              widget.duration != Duration.zero)
                            AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (final context, final child) =>
                                  ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                                child: LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.5),
                                  ),
                                  minHeight: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with longer duration for bounce effect
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Configure slide animation with bounce effect
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    // Configure fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Configure scale animation with bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // Configure progress bar animation
    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    // Configure icon rotation animation
    _iconRotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start entrance animation
    _controller.forward();

    // Configure auto-dismiss animation if duration is set
    if (widget.duration != Duration.zero) {
      _controller.animateTo(1.0, duration: widget.duration).whenComplete(() {
        if (mounted) {
          if (_controller.isCompleted) {
            _controller.reverse();
          }
        }
      });
    }
  }

  /// Dismisses the notification if it's dismissible
  void _dismiss() {
    if (widget.dismissible) {
      _controller.reverse();
    }
  }

  /// Returns the appropriate background color based on notification type
  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green.shade800;
      case NotificationType.error:
        return Colors.red.shade800;
      case NotificationType.warning:
        return Colors.orange.shade800;
      case NotificationType.info:
        return Colors.blue.shade800;
    }
  }

  /// Returns the appropriate icon based on notification type
  IconData _getDefaultIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
}
