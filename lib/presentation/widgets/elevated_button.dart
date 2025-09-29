// Custom Row Text widget
import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final void Function()? onPressed;
  final bool visibility;

  const ElevatedButtonWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.onPressed,
    required this.visibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Visibility(
        visible: visibility,
        child: Tooltip(
          message: hintText,
          child: ElevatedButton(onPressed: onPressed, child: Text(label)),
        ),
      ),
    );
  }
}
