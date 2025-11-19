// utils/snackbar_utils.dart
import 'package:flutter/material.dart';

class CustomSnackBar {
  static const Color primaryColor = Color(0xFF282C5C);
  static const Color backgroundColor = Colors.white;
  static const double borderRadius = 12.0;
  static const double elevation = 6.0;

  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: primaryColor,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context: context,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
    );
  }

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: primaryColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: primaryColor.withOpacity(0.6),
                  size: 18,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}