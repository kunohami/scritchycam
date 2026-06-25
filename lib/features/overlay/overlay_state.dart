import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayState {
  final File? image;
  final double opacity;
  final Offset position;
  final double scale;

  const OverlayState({
    this.image,
    this.opacity = 0.5,
    this.position = Offset.zero,
    this.scale = 1.0,
  });

  OverlayState copyWith({
    File? image,
    double? opacity,
    Offset? position,
    double? scale,
  }) {
    return OverlayState(
      image: image ?? this.image,
      opacity: opacity ?? this.opacity,
      position: position ?? this.position,
      scale: scale ?? this.scale,
    );
  }
}

class OverlayNotifier extends StateNotifier<OverlayState> {
  OverlayNotifier() : super(const OverlayState());

  void setImage(File image) {
    // Reset position and scale when a new image is loaded
    state = state.copyWith(image: image, position: Offset.zero, scale: 1.0);
  }

  void setOpacity(double value) {
    state = state.copyWith(opacity: value.clamp(0.0, 1.0));
  }

  void updatePosition(Offset delta) {
    state = state.copyWith(position: state.position + delta);
  }

  void updateScale(double newScale) {
    state = state.copyWith(scale: newScale.clamp(0.2, 5.0));
  }

  void clearImage() {
    state = const OverlayState();
  }
}

final overlayProvider = StateNotifierProvider<OverlayNotifier, OverlayState>(
  (_) => OverlayNotifier(),
);
