// Custom Row Text widget
import 'package:cvs/presentation/widgets/slide_switch.dart';
import 'package:flutter/material.dart';

class RowTextWidget extends StatefulWidget {
  final String label;
  final String hintText;
  final void Function(bool)? onChanged;
  final bool value;

  const RowTextWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.onChanged,
    this.value = false,
  });

  @override
  State<RowTextWidget> createState() => _RowTextWidgetState();
}

class _RowTextWidgetState extends State<RowTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: GestureDetector(
        onTap: () => widget.onChanged?.call(!widget.value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // pushes apart
          children: [
            Tooltip(
              preferBelow: false,
              message: widget.hintText,
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            CustomCupertinoSwitch(
              value: widget.value,
              onChanged: widget.onChanged,
              activeColor: Colors.green,
              inactiveColor: Colors.grey.shade300,
              thumbColor: Colors.white,
              width: 38,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
