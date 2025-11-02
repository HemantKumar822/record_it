import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/storage_service.dart';
import 'providers/app_providers.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred device orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize Hive storage
  final storageService = StorageService();
  await storageService.init();
  
  // Handle Flutter errors gracefully
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const RecordItApp(),
    ),
  );
}

class RecordItApp extends ConsumerStatefulWidget {
  const RecordItApp({super.key});

  @override
  ConsumerState<RecordItApp> createState() => _RecordItAppState();
}

class _RecordItAppState extends ConsumerState<RecordItApp> {
  @override
  Widget build(BuildContext context) {
    final storageService = ref.watch(storageServiceProvider);
    final hasSeenOnboarding = storageService.getSetting<bool>(
      'hasSeenOnboarding',
      defaultValue: false,
    );
    
    // Watch theme mode from settings
    final themeMode = ref.watch(themeModeProvider);
    
    // Determine brightness based on theme mode
    Brightness getBrightness() {
      if (themeMode == 'Dark') return Brightness.dark;
      if (themeMode == 'Light') return Brightness.light;
      // Auto mode - use system brightness
      return MediaQuery.platformBrightnessOf(context);
    }

    return CupertinoApp(
      title: 'Record It',
      theme: CupertinoThemeData(
        brightness: getBrightness(),
        primaryColor: CupertinoColors.systemBlue,
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Wrap with Material for compatibility with some widgets
        return Material(
          type: MaterialType.transparency,
          child: child ?? const SizedBox(),
        );
      },
      home: hasSeenOnboarding == true
          ? const HomeScreen()
          : OnboardingScreen(
              onComplete: () {
                storageService.saveSetting('hasSeenOnboarding', true);
                setState(() {});
              },
            ),
    );
  }
}
