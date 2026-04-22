import 'dart:async';
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
    widget.game.overlayManager.mobileControlsVisible.addListener(
      _onVisibilityChanged,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.game.overlayManager.mobileControlsVisible.value) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  void _onVisibilityChanged() {
    final shouldShow = widget.game.overlayManager.mobileControlsVisible.value;
    if (shouldShow == _visible) return;
    setState(() {
      _visible = shouldShow;
    });
  }

  @override
  void dispose() {
    widget.game.overlayManager.mobileControlsVisible.removeListener(
      _onVisibilityChanged,
    );
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

              return Stack(
                children: [
                  Positioned(
                    left: isSmall ? 12 : 24,
                    top: isSmall ? 12 : 24,
                    child: _ControlButton(
                      icon: Icons.pause_rounded,
                      size: buttonSize * 0.8,
                      iconSize: iconSize * 0.8,
                      onTap: widget.game.pauseGame,
                      onLongPress: () {
                        if (!widget.game.overlays.isActive('Debug')) {
                          widget.game.overlays.add('Debug');
                        }
                      },
                    ),
                  ),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.size = 64,
    this.iconSize = 36,
  });

  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double size;
  final double iconSize;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  Timer? _holdTimer;
  bool _isHolding = false;
  bool _longPressTriggered = false;

  void _startHold() {
    setState(() {
      _isHolding = true;
      _longPressTriggered = false;
    });
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isHolding) {
        _longPressTriggered = true;
        widget.onLongPress?.call();
        _stopHold();
      }
    });
  }

  void _stopHold() {
    if (mounted) {
      setState(() => _isHolding = false);
    }
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _stopHold(),
      onTapCancel: () => _stopHold(),
      onTap: () {
        if (!_longPressTriggered) {
          widget.onTap();
        }
      },
      child: AnimatedScale(
        scale: _isHolding ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _isHolding
                ? theme.colorScheme.primary.withValues(alpha: 0.9)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: _isHolding
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onPrimaryContainer,
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

class _HoldMoveButtonState extends State<_HoldMoveButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onPressChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _pressed
                ? theme.colorScheme.primary.withValues(alpha: 0.95)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _pressed ? 0.3 : 0.2),
                blurRadius: _pressed ? 15 : 10,
                offset: Offset(0, _pressed ? 8 : 4),
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
      ),
    );
  }
}
