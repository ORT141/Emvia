import 'dart:io' show File, Platform;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../l10n/app_localizations_gen.dart';
import '../glass_ui.dart';
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

final List<String> _cameraEquipFrames = List.unmodifiable(
  List.generate(
    24,
    (index) => 'assets/images/misc/camera/camera_${index + 1}.png',
  ),
);

class CameraOverlay extends StatefulWidget {
  final EmviaGame game;

  const CameraOverlay({super.key, required this.game});

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay>
    with TickerProviderStateMixin {
  static const Size _cameraFrameSize = Size(1900, 1025);

  late final AnimationController _equipController;
  late final AnimationController _shutterController;
  late final Animation<double> _shutterAnimation;
  CameraController? _controller;
  bool _isInitialized = false;
  String? _error;
  bool _isTakingPhoto = false;
  bool _isClosing = false;
  bool _didPrecacheFrames = false;

  bool get _useBlankPreviewOnWindows => !kIsWeb && Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _equipController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 650),
          reverseDuration: const Duration(milliseconds: 500),
        )..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shutterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shutterController, curve: Curves.easeInOut),
    );
    _equipController.forward();
    _initializeCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheFrames) return;

    for (final assetPath in _cameraEquipFrames) {
      precacheImage(AssetImage(assetPath), context);
    }

    _didPrecacheFrames = true;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _equipController.dispose();
    _shutterController.dispose();
    super.dispose();
  }

  bool get _isCameraEquipped =>
      !_isClosing &&
      !_equipController.isAnimating &&
      _equipController.status == AnimationStatus.completed;

  String get _currentCameraFrameAsset {
    final frameIndex = math.min(
      (_equipController.value * _cameraEquipFrames.length).floor(),
      _cameraEquipFrames.length - 1,
    );
    return _cameraEquipFrames[frameIndex];
  }

  double get _previewOpacity {
    final normalizedProgress = ((_equipController.value - 0.78) / 0.22)
        .clamp(0.0, 1.0)
        .toDouble();
    return Curves.easeOut.transform(normalizedProgress);
  }

  Future<void> _initializeCamera() async {
    if (_useBlankPreviewOnWindows) {
      return;
    }

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
    if (!_isCameraEquipped || !_isInitialized || _isTakingPhoto) return;

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

  Future<void> _closeCamera() async {
    if (_isClosing) return;

    setState(() => _isClosing = true);

    try {
      if (_equipController.value > 0.0) {
        await _equipController.reverse();
      }
    } finally {
      if (mounted) {
        widget.game.toggleCameraMode();
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
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey == LogicalKeyboardKey.keyC ||
            event.logicalKey == LogicalKeyboardKey.escape) {
          _closeCamera();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isCameraEquipped ? _takePhoto : null,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.85)),
            ),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: AspectRatio(
                      aspectRatio: _cameraFrameSize.aspectRatio,
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
                      onPressed: _isClosing ? null : _closeCamera,
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
      ),
    );
  }

  Widget _buildViewfinder() {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        final w = boxConstraints.maxWidth;
        final h = boxConstraints.maxHeight;
        final previewLeft = w * 0.232;
        final previewTop = h * 0.35;
        final previewWidth = w * (0.388);
        final previewHeight = h * (0.5);

        final showPreview =
            _isInitialized && _controller != null && _previewOpacity > 0.999;

        return Stack(
          children: [
            if (showPreview)
              Positioned(
                left: previewLeft,
                top: previewTop,
                width: previewWidth,
                height: previewHeight,
                child: Opacity(
                  opacity: _previewOpacity,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: previewWidth,
                        height: previewWidth / _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                ),
              )
            else if (_useBlankPreviewOnWindows && _previewOpacity > 0.999)
              Positioned(
                left: previewLeft,
                top: previewTop,
                width: previewWidth,
                height: previewHeight,
                child: ColoredBox(color: Colors.red.withValues(alpha: 0.92)),
              )
            else if (_error != null)
              Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(_currentCameraFrameAsset, fit: BoxFit.fill),
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
          child: GlassPanel(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              maxWidth: dialogMaxWidth,
              maxHeight: dialogMaxHeight,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 16 : 24,
                  isCompact ? 16 : 24,
                  isCompact ? 16 : 24,
                  isCompact ? 20 : 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassPanel(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(16),
                      alphaValue: 0.1,
                      child: ConstrainedBox(
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
                                  right: 16,
                                  bottom: 16,
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
                    ),
                    SizedBox(height: isCompact ? 16 : 24),
                    Text(
                      l?.camera_liam_title ?? 'Tag editor',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 12 : 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: tagKeys.map((key) {
                        final label = l != null ? _resolveTag(l, key) : key;
                        final isSelected = _selectedTag == key;
                        return GlassOptionChip(
                          label: label,
                          selected: isSelected,
                          onTap: () => setState(() {
                            _selectedTag = key;
                          }),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: isCompact ? 20 : 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassButton(
                          label: l?.cancel ?? 'Discard',
                          primary: false,
                          compact: isCompact,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        GlassButton(
                          label: l?.continueLabel ?? 'Save',
                          primary: true,
                          compact: isCompact,
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
                        ),
                      ],
                    ),
                  ],
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
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: BorderRadius.circular(10),
      blurSigma: 6,
      alphaValue: 0.5,
      child: Text(
        '#$label',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 0.8,
          shadows: [
            Shadow(color: Colors.black45, offset: Offset(0, 2), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}
