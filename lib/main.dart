import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/camera/camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    // ProviderScope is required at the root for Riverpod to work
    const ProviderScope(
      child: ScritchyCamApp(),
    ),
  );
}

class ScritchyCamApp extends StatelessWidget {
  const ScritchyCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScritchyCam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CameraScreen(),
    );
  }
}
