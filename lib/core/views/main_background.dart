import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A wrapper widget that applies the main application background.
///
/// This widget typically wraps a [Scaffold] with a transparent background
/// to show the underlying image.
class MainBackground extends StatelessWidget {
  final Widget child;

  const MainBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(color: AppTheme.backgroundLight, child: child);
  }
}
