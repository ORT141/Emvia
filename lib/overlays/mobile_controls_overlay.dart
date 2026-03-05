import 'package:flutter/material.dart';

import '../game/emvia_game.dart';

class MobileControlsOverlay extends StatelessWidget {
  const MobileControlsOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !game.isMobilePlatform,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 16,
              bottom: 20,
              child: Row(
                children: [
                  _HoldMoveButton(
                    icon: Icons.arrow_left_rounded,
                    onPressChanged: (isPressed) {
                      game.setMobileMoveX(isPressed ? -1 : 0);
                    },
                  ),
                  const SizedBox(width: 10),
                  _HoldMoveButton(
                    icon: Icons.arrow_right_rounded,
                    onPressChanged: (isPressed) {
                      game.setMobileMoveX(isPressed ? 1 : 0);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton.large(
                heroTag: 'backpack_mobile_button',
                onPressed: game.toggleBackpack,
                child: const Icon(Icons.backpack_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldMoveButton extends StatefulWidget {
  const _HoldMoveButton({required this.icon, required this.onPressChanged});

  final IconData icon;
  final ValueChanged<bool> onPressChanged;

  @override
  State<_HoldMoveButton> createState() => _HoldMoveButtonState();
}

class _HoldMoveButtonState extends State<_HoldMoveButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;
    widget.onPressChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onLongPressStart: (_) => _setPressed(true),
      onLongPressEnd: (_) => _setPressed(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _pressed
              ? theme.colorScheme.primary
              : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          size: 42,
          color: _pressed
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
