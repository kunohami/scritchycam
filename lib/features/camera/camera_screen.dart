import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../overlay/overlay_state.dart';
import '../../services/image_service.dart';
import 'camera_controller.dart';

enum _ActiveSlider { opacity, zoom }

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _uiVisible = true;
  _ActiveSlider? _activeSlider;

  void _toggleSlider(_ActiveSlider slider) {
    setState(() {
      _activeSlider = _activeSlider == slider ? null : slider;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);

    if (cameraState.error != null) {
      return Scaffold(body: Center(child: Text(cameraState.error!)));
    }

    if (!cameraState.isInitialized || cameraState.controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final topPadding = MediaQuery.of(context).padding.top + 8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CameraPreview(cameraState: cameraState),
          const _OverlayLayer(),
          // Top-right visibility toggle is always present
          Positioned(
            top: topPadding,
            right: 12,
            child: _CircleButton(
              icon: _uiVisible ? Icons.visibility_off : Icons.visibility,
              onTap: () => setState(() => _uiVisible = !_uiVisible),
              tooltip: _uiVisible ? 'Hide controls' : 'Show controls',
            ),
          ),
          if (_uiVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomControls(
                cameraState: cameraState,
                activeSlider: _activeSlider,
                onToggleSlider: _toggleSlider,
              ),
            ),
        ],
      ),
    );
  }
}

// Small translucent circular button used for the visibility toggle
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.black45,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _CameraPreview extends ConsumerStatefulWidget {
  const _CameraPreview({required this.cameraState});

  final CameraState cameraState;

  @override
  ConsumerState<_CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends ConsumerState<_CameraPreview> {
  double _baseZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.cameraState.controller!;
    final previewSize = controller.value.previewSize;

    return GestureDetector(
      onScaleStart: (_) => _baseZoom = widget.cameraState.currentZoom,
      onScaleUpdate: (details) {
        if (details.pointerCount < 2) return;
        ref.read(cameraProvider.notifier).setZoom(_baseZoom * details.scale);
      },
      // FittedBox + BoxFit.cover fills the screen cleanly without manual scale math.
      // previewSize is reported in landscape, so width/height are swapped for portrait.
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize?.height ?? 1,
            height: previewSize?.width ?? 1,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

// Handles the transparent image overlay, drag, and pinch-to-scale gestures
class _OverlayLayer extends ConsumerStatefulWidget {
  const _OverlayLayer();

  @override
  ConsumerState<_OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends ConsumerState<_OverlayLayer> {
  double _baseScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final overlay = ref.watch(overlayProvider);
    if (overlay.image == null) return const SizedBox.shrink();

    return GestureDetector(
      onScaleStart: (_) => _baseScale = overlay.scale,
      onScaleUpdate: (details) {
        final notifier = ref.read(overlayProvider.notifier);
        // Single finger = drag overlay; two fingers = scale overlay
        if (details.pointerCount == 1) {
          notifier.updatePosition(details.focalPointDelta);
        } else {
          notifier.updateScale(_baseScale * details.scale);
        }
      },
      child: Transform.translate(
        offset: overlay.position,
        child: Transform.scale(
          scale: overlay.scale,
          child: Opacity(
            opacity: overlay.opacity,
            child: Image.file(
              overlay.image!,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends ConsumerWidget {
  const _BottomControls({
    required this.cameraState,
    required this.activeSlider,
    required this.onToggleSlider,
  });

  final CameraState cameraState;
  final _ActiveSlider? activeSlider;
  final void Function(_ActiveSlider) onToggleSlider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlay = ref.watch(overlayProvider);
    final overlayNotifier = ref.read(overlayProvider.notifier);
    final cameraNotifier = ref.read(cameraProvider.notifier);
    final hasZoom = cameraState.maxZoom > cameraState.minZoom;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active slider appears above the button row
              if (activeSlider == _ActiveSlider.opacity && overlay.image != null)
                _SliderRow(
                  icon: Icons.opacity,
                  value: overlay.opacity,
                  min: 0.0,
                  max: 1.0,
                  label: '${(overlay.opacity * 100).round()}%',
                  onChanged: overlayNotifier.setOpacity,
                ),
              if (activeSlider == _ActiveSlider.zoom && hasZoom)
                _SliderRow(
                  icon: Icons.zoom_in,
                  value: cameraState.currentZoom,
                  min: cameraState.minZoom,
                  max: cameraState.maxZoom,
                  label: '${cameraState.currentZoom.toStringAsFixed(1)}x',
                  onChanged: cameraNotifier.setZoom,
                ),
              // Main button row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Left column: slider toggles stacked above gallery
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (overlay.image != null)
                        _ToggleIconButton(
                          icon: Icons.opacity,
                          active: activeSlider == _ActiveSlider.opacity,
                          tooltip: 'Overlay opacity',
                          onTap: () => onToggleSlider(_ActiveSlider.opacity),
                        ),
                      if (hasZoom)
                        _ToggleIconButton(
                          icon: Icons.zoom_in,
                          active: activeSlider == _ActiveSlider.zoom,
                          tooltip: 'Zoom',
                          onTap: () => onToggleSlider(_ActiveSlider.zoom),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final file = await ImageService.pickFromGallery();
                              if (file != null) overlayNotifier.setImage(file);
                            },
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            tooltip: 'Pick reference image',
                          ),
                          if (overlay.image != null)
                            IconButton(
                              onPressed: overlayNotifier.clearImage,
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              tooltip: 'Remove overlay',
                            ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Bottom right: camera switch
                  IconButton(
                    onPressed: cameraNotifier.switchCamera,
                    icon: const Icon(Icons.flip_camera_android, color: Colors.white, size: 28),
                    tooltip: 'Switch camera',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  final IconData icon;
  final double value;
  final double min;
  final double max;
  final String label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          Expanded(
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
          SizedBox(
            width: 38,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleIconButton extends StatelessWidget {
  const _ToggleIconButton({
    required this.icon,
    required this.active,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(
        icon,
        // Brighter when slider is open
        color: active ? Colors.white : Colors.white54,
      ),
    );
  }
}
