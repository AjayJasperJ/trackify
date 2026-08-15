import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'features/authentication/providers/auth_provider.dart';
import 'features/onboarding/providers/onboarding_providers.dart';
import 'core/presentation/screens/splash_screen.dart';

class TrackifyApp extends ConsumerWidget {
  const TrackifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final needsOnboarding = ref.watch(needsOnboardingProvider);
    
    // Safely get screen width without MediaQuery at the root, guarding against empty views on launch
    final dispatcher = PlatformDispatcher.instance;
    final view = dispatcher.implicitView ?? (dispatcher.views.isNotEmpty ? dispatcher.views.first : null);
    final width = view != null ? (view.physicalSize.width / view.devicePixelRatio) : 390.0;
    final displaysize = width < 402;

    Widget app;
    if (authState.isLoading || needsOnboarding.isLoading) {
      app = MaterialApp(
        title: 'Trackify',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    } else {
      final router = ref.watch(routerProvider);
      app = MaterialApp.router(
        title: 'Trackify',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      );
    }
    return ScreenUtilInit(
      key: ValueKey('displaySize : $displaysize'),
      designSize: const Size(402, 862),
      minTextAdapt: true,
      splitScreenMode: true,
      enableScaleText: () => displaysize,
      enableScaleWH: () => displaysize,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFE8E8ED),
          body: Center(
            child: Container(
              width: 390,
              height: 844,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: app,
            ),
          ),
        ),
      ),
    );
  }
}
