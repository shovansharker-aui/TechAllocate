import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Used on screens that are at the top level of the application.
///
/// When there is another screen above the current one, Flutter's normal
/// navigation/back behavior is used. When this is the root screen, the user
/// gets a confirmation before the Android app is closed/minimized.
class RootBackScope extends StatelessWidget {
  final Widget child;
  final String title;
  final String message;

  const RootBackScope({
    super.key,
    required this.child,
    this.title = 'Exit TechAllocate?',
    this.message = 'There is no previous screen. Do you want to leave this page?',
  });

  Future<void> _confirmExit(BuildContext context) async {
    if (kIsWeb) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay'),
            ),
          ],
        ),
      );
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: child,
    );
  }
}
