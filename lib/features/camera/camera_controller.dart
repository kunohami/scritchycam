import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/camera_service.dart';

class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final String? error;
  final double minZoom;
  final double maxZoom;
  final double currentZoom;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.error,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
    this.currentZoom = 1.0,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    String? error,
    double? minZoom,
    double? maxZoom,
    double? currentZoom,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      currentZoom: currentZoom ?? this.currentZoom,
    );
  }
}

class CameraNotifier extends StateNotifier<CameraState> {
  CameraNotifier() : super(const CameraState()) {
    _init();
  }

  Future<void> _init() async {
    final cameras = await CameraService.getAvailableCameras();
    if (cameras.isEmpty) {
      state = const CameraState(error: 'No cameras found on this device.');
      return;
    }

    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    await _setupController(back);
  }

  Future<void> _setupController(CameraDescription camera) async {
    final controller = CameraService.createController(camera);
    await controller.initialize();

    final minZoom = await controller.getMinZoomLevel();
    final maxZoom = await controller.getMaxZoomLevel();

    state = CameraState(
      controller: controller,
      isInitialized: true,
      minZoom: minZoom,
      maxZoom: maxZoom,
      currentZoom: minZoom,
    );
  }

  Future<void> setZoom(double zoom) async {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    final clamped = zoom.clamp(state.minZoom, state.maxZoom);
    await controller.setZoomLevel(clamped);
    state = state.copyWith(currentZoom: clamped);
  }

  Future<void> switchCamera() async {
    final cameras = await CameraService.getAvailableCameras();
    if (cameras.length < 2) return;

    final current = state.controller?.description;
    final next = cameras.firstWhere(
      (c) => c != current,
      orElse: () => cameras.first,
    );

    await state.controller?.dispose();
    await _setupController(next);
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>(
  (_) => CameraNotifier(),
);
