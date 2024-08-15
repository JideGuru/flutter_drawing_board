import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_platform/universal_platform.dart';

typedef BoolCallback = void Function(bool);

class HotkeyListener extends StatefulWidget {
  final Widget child;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onChangeTool;
  final BoolCallback? onShiftPressed;

  const HotkeyListener({
    super.key,
    required this.child,
    this.onUndo,
    this.onRedo,
    this.onChangeTool,
    this.onShiftPressed,
  });

  @override
  State<HotkeyListener> createState() => _HotkeyListenerState();
}

class _HotkeyListenerState extends State<HotkeyListener> {
  final FocusNode _focusNode = FocusNode()..requestFocus();
  final isMacOS = UniversalPlatform.isMacOS;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // ctrl + z
        SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: !isMacOS,
          meta: isMacOS,
        ): () {
          widget.onUndo?.call();
        },
        // ctrl + y
        SingleActivator(
          LogicalKeyboardKey.keyY,
          control: !isMacOS,
          meta: isMacOS,
        ): () {
          widget.onRedo?.call();
        },
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        child: widget.child,
      ),
    );
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      // when shift is pressed, we want to change the tool
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        widget.onShiftPressed?.call(true);
      }
    } else if (event is KeyUpEvent) {
      // when shift is released, we want to change the tool back to the previous one
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
          event.logicalKey == LogicalKeyboardKey.shiftRight) {
        widget.onShiftPressed?.call(false);
      }
    }
  }
}
