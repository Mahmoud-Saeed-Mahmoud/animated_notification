library;

import 'dart:async';

import 'package:flutter/material.dart';

class AnimatedNotification extends StatefulWidget {
  final String message;
  final Duration duration;
  final NotificationType type;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool showProgressBar;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool dismissible;

  const AnimatedNotification({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.type = NotificationType.info,
    this.onTap,
    this.icon,
    this.showProgressBar = true,
    this.actionLabel,
    this.onActionPressed,
    this.dismissible = true,
  });

  @override
  State<AnimatedNotification> createState() => _AnimatedNotificationState();
}

// Enhanced notification service
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  OverlayEntry? _currentEntry;
  Timer? _timer;

  factory NotificationService() => _instance;
  NotificationService._internal();

  void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
    _timer?.cancel();
    _timer = null;
  }

  void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    Widget? icon,
    bool showProgressBar = true,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool dismissible = true,
  }) {
    _currentEntry?.remove();
    _timer?.cancel();

    OverlayState? overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
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

    if (duration != Duration.zero) {
      _timer = Timer(duration + const Duration(milliseconds: 600), () {
        _currentEntry?.remove();
        _currentEntry = null;
      });
    }
  }
}

enum NotificationType { success, error, warning, info }

class _AnimatedNotificationState extends State<AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotationAnimation;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap ?? _dismiss,
              onHorizontalDragEnd: (_) => _dismiss(),
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
                                builder: (context, child) {
                                  return Transform(
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
                                  );
                                },
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
                            builder: (context, child) {
                              return ClipRRect(
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
                              );
                            },
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly longer for bounce
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5), // Start further up for bounce effect
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // Bounce effect
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

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

  void _dismiss() {
    if (widget.dismissible) {
      _controller.reverse();
    }
  }

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
