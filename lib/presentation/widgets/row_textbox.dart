// Custom Row Text widget
import 'package:cvs/presentation/widgets/slide_switch.dart';
import 'package:flutter/material.dart';

class RowTextWidget extends StatelessWidget {
  final String label;
  final String hintText;
  final void Function(bool)? onChanged;
  final bool value;
  final bool show;

  const RowTextWidget({
    super.key,
    required this.label,
    required this.hintText,
    this.onChanged,
    required this.value,
    this.show = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: GestureDetector(
        onTap: () => onChanged?.call(!value),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // pushes apart
          children: [
            Tooltip(
              preferBelow: false,
              message: hintText,
              child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Visibility(
              visible: show,
              child: CustomCupertinoSwitch(
                // disabled: disabled,
                value: value,
                onChanged: onChanged,
                activeColor: Colors.green,
                inactiveColor: Colors.grey.shade300,
                thumbColor: Colors.white,
                width: 38,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
