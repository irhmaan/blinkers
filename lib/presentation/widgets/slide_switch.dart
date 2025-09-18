import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A compact, customizable Cupertino-like switch.
/// - `value` and `onChanged` behave like a normal Switch.
/// - Customize sizes, colors, duration, and padding.
class CustomCupertinoSwitch extends StatefulWidget {
  const CustomCupertinoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width = 50.0,
    this.height = 30.0,
    this.padding = 2.0,
    this.duration = const Duration(milliseconds: 200),
    this.disabled = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor; // track color when true
  final Color? inactiveColor; // track color when false
  final Color? thumbColor;
  final double width;
  final double height;
  final double padding;
  final Duration duration;
  final bool disabled;

  @override
  State<CustomCupertinoSwitch> createState() => _CustomCupertinoSwitchState();
}

class _CustomCupertinoSwitchState extends State<CustomCupertinoSwitch>
    with TickerProviderStateMixin {
  late bool _value;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
  }

  @override
  void didUpdateWidget(covariant CustomCupertinoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() => _value = widget.value);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.disabled) return;
    widget.onChanged?.call(!_value);
    // optimistic UI update
    setState(() => _value = !_value);
  }

  @override
  Widget build(BuildContext context) {
    final Color defaultActive = widget.activeColor ?? Color(0xFF34C759);
    final Color defaultInactive = widget.inactiveColor ?? Colors.grey.shade300;
    final Color defaultThumb = widget.thumbColor ?? Colors.white;
    final double thumbSize = widget.height - 2 * widget.padding;
    final double alignX = _value ? 1.0 : -1.0;

    return Semantics(
      container: true,
      button: true,
      toggled: _value,
      enabled: !widget.disabled,
      label: 'Toggle',
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: _toggle,
        behavior: HitTestBehavior.translucent,
        child: FocusableActionDetector(
          enabled: !widget.disabled,
          mouseCursor:
              widget.disabled
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
          onShowHoverHighlight: (_) {},
          onShowFocusHighlight: (_) {},
          shortcuts: <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) => _toggle(),
            ),
          },
          child: AnimatedScale(
            scale: 1.0 - _scaleController.value,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: widget.duration,
              width: widget.width,
              height: widget.height,
              padding: EdgeInsets.all(widget.padding),
              decoration: BoxDecoration(
                color: _value ? defaultActive : defaultInactive,
                borderRadius: BorderRadius.circular(widget.height / 2),
                boxShadow: [
                  // subtle shadow for thumb elevation when ON
                  if (_value)
                    BoxShadow(
                      color: (defaultActive).withValues(
                        red: 0.25,
                        blue: 0.25,
                        green: 0.25,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth =
                      constraints.maxWidth - 2 * widget.padding;
                  final thumbDiameter = thumbSize.clamp(0.0, availableWidth);
                  return Stack(
                    children: [
                      // Optional track inner effect (gloss)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _value ? 0.06 : 0.0,
                            duration: widget.duration,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  widget.height / 2,
                                ),
                                // slight gradient/overlay to feel more Cupertino-like
                                gradient:
                                    _value
                                        ? LinearGradient(
                                          colors: [
                                            Colors.white.withValues(
                                              red: 0.06,
                                              blue: 0.06,
                                              green: 0.06,
                                            ),
                                            Colors.white.withValues(
                                              red: 0.06,
                                              blue: 0.06,
                                              green: 0.06,
                                            ),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                        : null,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Thumb
                      AnimatedAlign(
                        duration: widget.duration,
                        curve: Curves.easeInOut,
                        alignment: Alignment(alignX, 0.0),
                        child: Container(
                          width: thumbDiameter,
                          height: thumbDiameter,
                          decoration: BoxDecoration(
                            color: defaultThumb,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  red: 0.25,
                                  blue: 0.25,
                                  green: 0.25,
                                ),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
