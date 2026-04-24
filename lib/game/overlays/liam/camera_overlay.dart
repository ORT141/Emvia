import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../emvia_game.dart';

class CameraOverlay extends StatefulWidget {
  final EmviaGame game;

  const CameraOverlay({super.key, required this.game});

  @override
  State<CameraOverlay> createState() => _CameraOverlayState();
}

class _CameraOverlayState extends State<CameraOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _shutterController;
  late Animation<double> _shutterAnimation;
  CameraController? _controller;
  bool _isInitialized = false;
  String? _error;

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

  Future<void> _initializeCamera() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        if (mounted) {
          setState(() {
            _error = 'Camera permission denied';
          });
        }
        return;
      }
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _error = 'No cameras found';
          });
        }
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error initializing camera: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _shutterController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _printCameraUV() {
    final game = widget.game;
    final scene = game.currentScene;
    if (scene == null) return;

    final center = game.size / 2;
    final worldOffset = game.worldRoot.position;
    final zoom = game.worldRoot.scale.x;
    final worldPos = (center - worldOffset) / zoom;

    final bgPos = scene.background.position;
    final bgSize = scene.background.size;
    final u = (worldPos.x - bgPos.x) / bgSize.x;
    final v = (worldPos.y - bgPos.y) / bgSize.y;

    debugPrint(
      'CAMERA FOCUS UV: (${u.toStringAsFixed(4)}, ${v.toStringAsFixed(4)})',
    );
  }

  void _takePhoto() async {
    if (!_isInitialized) return;
    _printCameraUV();
    await _shutterController.forward();
    await _shutterController.reverse();
    // In a real device, you could also call _controller!.takePicture();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Darkened Background
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.85)),
        ),

        // Camera Body
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
                  child: LayoutBuilder(
                    builder: (context, boxConstraints) {
                      final w = boxConstraints.maxWidth;
                      final h = boxConstraints.maxHeight;

                      return Stack(
                        children: [
                          // Real Camera Preview (inside the viewfinder)
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
                                    height: (w * (561 / 1516)) /
                                        _controller!.value.aspectRatio,
                                    child: CameraPreview(_controller!),
                                  ),
                                ),
                              ),
                            )
                          else if (_error != null)
                            Center(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          else
                            const Center(child: CircularProgressIndicator()),

                          // The camera overlay asset itself (with transparent hole)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Image.asset(
                                'assets/images/misc/camera-overlay.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          // Shutter Button / Interaction Area
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _takePhoto,
                              behavior: HitTestBehavior.opaque,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),

        // Shutter Flash
        FadeTransition(
          opacity: _shutterAnimation,
          child: Container(color: Colors.white),
        ),

        // Minimal UI
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: widget.game.toggleCameraMode,
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
