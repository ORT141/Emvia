import 'dart:io' show File, Platform;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../l10n/app_localizations_gen.dart';
import '../../emvia_game.dart';
import '../../models/captured_photo.dart';

const Map<int, List<String>> _sceneTags = {
  2: ['tag_freely', 'tag_impossible', 'tag_difficult'],
  3: ['tag_obstacle', 'tag_danger', 'tag_uncomfortable'],
  4: ['tag_control', 'tag_dependency', 'tag_help'],
  5: ['tag_strength', 'tag_style', 'tag_personality'],
  6: ['tag_unreachable', 'tag_barrier', 'tag_injustice'],
  7: ['tag_accessibility', 'tag_solution', 'tag_freedom'],
};

class CameraOverlay extends StatefulWidget {
  final EmviaGame game;

  const CameraOverlay({super.key, required this.game});

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shutterController;
  late final Animation<double> _shutterAnimation;
  CameraController? _controller;
  bool _isInitialized = false;
  String? _error;
  bool _isTakingPhoto = false;

  @override
  void initState() {
    super.initState();
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shutterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOut),
    );
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _shutterController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!mounted) return;
        setState(() {
          _error = 'Camera permission denied';
        });
        return;
      }
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'No camera available';
        });
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!_isInitialized || _isTakingPhoto) return;

    final liamState = widget.game.liamState;
    if (liamState == null || !liamState.canCaptureMore) return;

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() => _isTakingPhoto = true);

    try {
      await _shutterController.forward();
      await _shutterController.reverse();

      final file = await controller.takePicture();
      if (!mounted) return;

      await _openTagEditorModal(file);
    } catch (e) {
      debugPrint('Camera capture failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
      }
    }
  }

  Future<void> _openTagEditorModal(XFile file) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _TagEditorDialog(game: widget.game, file: file);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _takePhoto,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.85)),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth * 0.95;
                final maxHeight = constraints.maxHeight * 0.85;
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1516 / 1010,
                    child: _buildViewfinder(),
                  ),
                );
              },
            ),
          ),
          FadeTransition(
            opacity: _shutterAnimation,
            child: Container(color: Colors.white),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: widget.game.toggleCameraMode,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final w = boxConstraints.maxWidth;
        final h = boxConstraints.maxHeight;

        return Stack(
          children: [
            if (_isInitialized && _controller != null)
              Positioned(
                left: w * (443 / 1516),
                top: h * (309 / 1010),
                width: w * (561 / 1516),
                height: h * (394 / 1010),
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: w * (561 / 1516),
                      height:
                          (w * (561 / 1516)) / _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
              )
            else if (_error != null)
              Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
            else
              const Center(child: CircularProgressIndicator()),
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/misc/camera-overlay.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildCapturedImage(XFile file) {
  if (kIsWeb) {
    return Image.network(file.path, fit: BoxFit.cover);
  }
  return Image.file(File(file.path), fit: BoxFit.cover);
}

String _resolveTag(AppLocalizationsGen l, String key) {
  switch (key) {
    case 'tag_freely':
      return l.tag_freely;
    case 'tag_impossible':
      return l.tag_impossible;
    case 'tag_difficult':
      return l.tag_difficult;
    case 'tag_obstacle':
      return l.tag_obstacle;
    case 'tag_danger':
      return l.tag_danger;
    case 'tag_uncomfortable':
      return l.tag_uncomfortable;
    case 'tag_control':
      return l.tag_control;
    case 'tag_dependency':
      return l.tag_dependency;
    case 'tag_help':
      return l.tag_help;
    case 'tag_strength':
      return l.tag_strength;
    case 'tag_style':
      return l.tag_style;
    case 'tag_personality':
      return l.tag_personality;
    case 'tag_unreachable':
      return l.tag_unreachable;
    case 'tag_barrier':
      return l.tag_barrier;
    case 'tag_injustice':
      return l.tag_injustice;
    case 'tag_accessibility':
      return l.tag_accessibility;
    case 'tag_solution':
      return l.tag_solution;
    case 'tag_freedom':
      return l.tag_freedom;
    default:
      return key;
  }
}

class _TagButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TagButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : Colors.white54,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TagEditorDialog extends StatefulWidget {
  final EmviaGame game;
  final XFile file;

  const _TagEditorDialog({required this.game, required this.file});

  @override
  State<_TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<_TagEditorDialog> {
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizationsGen.of(context);
    final sceneIndex = widget.game.sceneIndex;
    final tagKeys = _sceneTags[sceneIndex] ?? _sceneTags[2]!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final horizontalInset = isCompact ? 12.0 : 20.0;
        final dialogMaxWidth = math.min(constraints.maxWidth, 860.0);
        final dialogMaxHeight = MediaQuery.sizeOf(context).height * 0.9;
        final previewMaxHeight = dialogMaxHeight * (isCompact ? 0.42 : 0.58);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: isCompact ? 12.0 : 20.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogMaxWidth,
              maxHeight: dialogMaxHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B0B0F),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 12 : 16,
                    isCompact ? 12 : 16,
                    isCompact ? 12 : 16,
                    isCompact ? 14 : 18,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: previewMaxHeight,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1516 / 1010,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _buildCapturedImage(widget.file),
                              ),

                              if (_selectedTag != null)
                                Positioned(
                                  right: 24,
                                  bottom: 24,
                                  child: _TagStamp(
                                    label: l != null
                                        ? _resolveTag(l, _selectedTag!)
                                        : _selectedTag!,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 12 : 16),
                      Text(
                        l?.camera_liam_title ?? 'Tag editor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isCompact ? 10 : 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: tagKeys.map((key) {
                          final label = l != null ? _resolveTag(l, key) : key;
                          final isSelected = _selectedTag == key;
                          return _TagButton(
                            label: label,
                            selected: isSelected,
                            onTap: () => setState(() {
                              _selectedTag = key;
                            }),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: isCompact ? 14 : 16),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 8,
                        spacing: 12,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.white70,
                            ),
                            label: Text(
                              l?.cancel ?? 'Discard',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _selectedTag == null
                                ? null
                                : () {
                                    widget.game.liamState?.addPhoto(
                                      CapturedPhoto(
                                        path: widget.file.path,
                                        tagKey: _selectedTag!,
                                        sceneIndex: widget.game.sceneIndex,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                            icon: const Icon(Icons.check),
                            label: Text(l?.continueLabel ?? 'Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TagStamp extends StatelessWidget {
  final String label;

  const _TagStamp({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white70),
      ),
      child: Text(
        '#$label',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
