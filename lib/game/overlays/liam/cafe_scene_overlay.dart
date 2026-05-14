import 'package:flutter/material.dart';
import 'package:emvia/l10n/app_localizations_gen.dart';

import '../../emvia_game.dart';
import '../../managers/game_state/game_state.dart';

class CafeSceneOverlay extends StatefulWidget {
  final EmviaGame game;
  final String imagePath;
  final VoidCallback onDismiss;
  final String? text;
  final String? speakerName;

  const CafeSceneOverlay({
    super.key,
    required this.game,
    required this.imagePath,
    required this.onDismiss,
    this.text,
    this.speakerName,
  });

  @override
  State<CafeSceneOverlay> createState() => _CafeSceneOverlayState();
}

class _CafeSceneOverlayState extends State<CafeSceneOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final AnimationController _dismissController;
  late final Animation<double> _blackAnim;
  LiamBoundaryResponse? _selectedResponse;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.value = 1.0;
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _blackAnim = CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _dismissController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _isBoundaryChoiceScene => widget.speakerName != null;

  Future<void> _handleDismissTap() async {
    if (_isDismissing) return;
    if (_isBoundaryChoiceScene && _selectedResponse == null) return;

    _isDismissing = true;
    try {
      await _dismissController.forward(from: 0);
      if (!mounted) return;
      widget.onDismiss();
    } finally {
      if (mounted) {
        _isDismissing = false;
      }
    }
  }

  void _selectResponse(LiamBoundaryResponse response) {
    if (_selectedResponse != null || _isDismissing) return;

    setState(() {
      _selectedResponse = response;
    });

    widget.game.liamState?.boundaryResponse = response;
  }

  String _responseText(AppLocalizationsGen loc, LiamBoundaryResponse response) {
    switch (response) {
      case LiamBoundaryResponse.explain:
        return loc.liam_boundary_response_explain;
      case LiamBoundaryResponse.joke:
        return loc.liam_boundary_response_joke;
      case LiamBoundaryResponse.respondSharply:
        return loc.liam_boundary_response_sharp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsGen.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleDismissTap,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(widget.imagePath, fit: BoxFit.cover),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            if (widget.text != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 72,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: Container(
                        key: ValueKey<String>(
                          _isBoundaryChoiceScene
                              ? (_selectedResponse?.name ?? 'choices')
                              : 'text',
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.speakerName != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  widget.speakerName!,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD54F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            Text(
                              _isBoundaryChoiceScene && _selectedResponse != null
                                  ? _responseText(loc, _selectedResponse!)
                                  : widget.text!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            if (_isBoundaryChoiceScene &&
                                _selectedResponse == null) ...[
                              const SizedBox(height: 14),
                              Text(
                                loc.liam_boundary_choice_prompt,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.86),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildChoiceButton(
                                    label: loc.liam_boundary_choice_explain,
                                    onPressed: () => _selectResponse(
                                      LiamBoundaryResponse.explain,
                                    ),
                                  ),
                                  _buildChoiceButton(
                                    label: loc.liam_boundary_choice_joke,
                                    onPressed: () => _selectResponse(
                                      LiamBoundaryResponse.joke,
                                    ),
                                  ),
                                  _buildChoiceButton(
                                    label: loc.liam_boundary_choice_sharp,
                                    onPressed: () => _selectResponse(
                                      LiamBoundaryResponse.respondSharply,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_isBoundaryChoiceScene || _selectedResponse != null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 28,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      child: Text(loc.overlay_tap_to_continue),
                    ),
                  ),
                ),
              ),
            IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _blackAnim,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withValues(alpha: _blackAnim.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
