import 'package:flutter/material.dart';

/// A single, themed loading indicator used across the app so progress UI looks
/// identical on every screen and platform. Colour and stroke come from the
/// Material 3 [ProgressIndicatorThemeData]; pass [color] only to override
/// (e.g. on a coloured button).
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.size = 28,
    this.strokeWidth = 3,
    this.color,
  });

  /// A small inline spinner sized to sit inside buttons / list rows.
  const AppLoading.small({super.key, this.color})
      : size = 18,
        strokeWidth = 2;

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
        strokeCap: StrokeCap.round,
      ),
    );
  }

  /// Convenience: a centered [AppLoading] for full-screen / empty states.
  static Widget centered({double size = 32}) =>
      Center(child: AppLoading(size: size));
}
