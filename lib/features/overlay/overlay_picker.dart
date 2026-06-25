import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/image_service.dart';
import 'overlay_state.dart';

class OverlayControls extends ConsumerWidget {
  const OverlayControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlay = ref.watch(overlayProvider);
    final notifier = ref.read(overlayProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (overlay.image != null) ...[
          // Opacity slider shown only when an image is loaded
          Row(
            children: [
              const Icon(Icons.opacity, color: Colors.white, size: 18),
              Expanded(
                child: Slider(
                  value: overlay.opacity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: notifier.setOpacity,
                ),
              ),
            ],
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () async {
                final file = await ImageService.pickFromGallery();
                if (file != null) notifier.setImage(file);
              },
              icon: const Icon(Icons.image, color: Colors.white),
              tooltip: 'Pick reference image',
            ),
            if (overlay.image != null)
              IconButton(
                onPressed: notifier.clearImage,
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Remove overlay',
              ),
          ],
        ),
      ],
    );
  }
}
