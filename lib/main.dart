import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackify/app.dart';
import 'firebase_options.dart';

Future<void> _writeLog(String message) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/trackify_crash_log.txt');
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('[$timestamp] $message\n', mode: FileMode.append);
  } catch (e) {
    debugPrint('Failed to write log: $e');
  }
}

Future<void> _initCrashLogging() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      // Capture Flutter framework errors + async zone errors.
      FlutterError.onError = (FlutterErrorDetails details) async {
        FlutterError.presentError(details);
        final entry =
            'FLUTTER_ERROR: ${details.exceptionAsString()}\n${details.stack}';
        await _writeLog(entry);
        try {
          // Best-effort Crashlytics breadcrumb capture.
          // ignore: avoid_print
          print(entry);
        } catch (_) {}
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _writeLog('ASYNC_ERROR: $error\n$stack');
        return true;
      };

      await _writeLog(
        'Crash logging initialized.\n'
        'OS: ${Platform.operatingSystem}\n'
        'Version: ${Platform.operatingSystemVersion}\n'
        'Dart: ${Platform.version}',
      );
    } else {
      await _writeLog('Firebase not initialized; crash logging deferred.');
    }
  } catch (e) {
    await _writeLog('Crash logging init failed: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _writeLog(
      'APP_STARTED\nOS: ${Platform.operatingSystem}\nOSVersion: ${Platform.operatingSystemVersion}\nDart: ${Platform.version}',
    );
  } catch (e) {
    // ignore
  }

  try {
    _writeLog('App starting...');
    // Temporarily disabling crash logging for isolation
    // await _initCrashLogging();
    _writeLog('Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      // Temporarily disabling Firebase initialization for isolation
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
    }
    _writeLog('Firebase initialized. Running app.');
    // Simplify root app for testing
    runApp(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
              child: Text('Startup Successful',
                  style: TextStyle(fontSize: 24))),
        ),
      ),
    );
  } catch (e, stack) {
    await _writeLog('MAIN_FAIL: $e\n$stack');
    rethrow;
  }
}
