import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

/// Single home icon button that navigates to HomeScreen and clears the stack.
Widget homeIconButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.home),
    tooltip: 'Go to Home',
    onPressed: () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    },
  );
}
