import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, String type) {
  Color toastColor = Colors.green;
  IconData icon = Icons.check_circle_outlined;
  if (type == 'error') {
    toastColor = Colors.red;
    icon = Icons.error_outline;
  } else if (type == 'info') {
    toastColor = Theme.of(context).colorScheme.inversePrimary;
    icon = Icons.info_outline;
  }
    final snackBar = SnackBar(
      content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 10), Text(message)]), //Text(message),
      backgroundColor: toastColor,
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
