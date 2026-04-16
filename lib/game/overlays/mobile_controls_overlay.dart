import 'package:flutter/material.dart';

import '../emvia_game.dart';

class MobileControlsOverlay extends StatefulWidget {
  const MobileControlsOverlay({super.key, required this.game});

  final EmviaGame game;

  @override
  State<MobileControlsOverlay> createState() => _MobileControlsOverlayState();
}

class _MobileControlsOverlayState extends State<MobileControlsOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _visible = false;
    widget.game.mobileControlsVisible.addListener(_onVisibilityChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.game.mobileControlsVisible.value) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  void _onVisibilityChanged() {
    final shouldShow = widget.game.mobileControlsVisible.value;
    if (shouldShow == _visible) return;
    setState(() {
      _visible = shouldShow;
    });
  }

  @override
  void dispose() {
    widget.game.mobileControlsVisible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.game.isMobilePlatform || !_visible,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        onEnd: () {
          if (!_visible) {
            if (widget.game.overlays.isActive('MobileControls')) {
              widget.game.overlays.remove('MobileControls');
            }
          }
        },
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall =
                  constraints.maxHeight < 400 || constraints.maxWidth < 600;
              final buttonSize = isSmall ? 64.0 : 84.0;
              final iconSize = isSmall ? 36.0 : 48.0;
              final fabSize = isSmall ? 64.0 : 84.0;
              final fabIconSize = isSmall ? 28.0 : 40.0;

              return Stack(
                children: [
                  Positioned(
                    left: isSmall ? 12 : 24,
                    bottom: isSmall ? 12 : 24,
                    child: Row(
                      children: [
                        _HoldMoveButton(
                          icon: Icons.arrow_left_rounded,
                          size: buttonSize,
                          iconSize: iconSize,
                          onPressChanged: (isPressed) {
                            widget.game.setMobileMoveX(isPressed ? -1 : 0);
                          },
                        ),
                        SizedBox(width: isSmall ? 16 : 24),
                        _HoldMoveButton(
                          icon: Icons.arrow_right_rounded,
                          size: buttonSize,
                          iconSize: iconSize,
                          onPressChanged: (isPressed) {
                            widget.game.setMobileMoveX(isPressed ? 1 : 0);
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: isSmall ? 12 : 24,
                    bottom: isSmall ? 12 : 28,
                    child: SizedBox(
                      width: fabSize,
                      height: fabSize,
                      child: FloatingActionButton(
                        heroTag: 'backpack_mobile_button',
                        onPressed: widget.game.toggleBackpack,
                        elevation: 6,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Icon(Icons.backpack_rounded, size: fabIconSize),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HoldMoveButton extends StatefulWidget {
  const _HoldMoveButton({
    required this.icon,
    required this.onPressChanged,
    this.size = 84,
    this.iconSize = 48,
  });

  final IconData icon;
  final ValueChanged<bool> onPressChanged;
  final double size;
  final double iconSize;

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
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _pressed
              ? theme.colorScheme.primary.withValues(alpha: 0.9)
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(widget.size * 0.24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          size: widget.iconSize,
          color: _pressed
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
