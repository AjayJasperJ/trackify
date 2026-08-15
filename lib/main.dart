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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Intercept all Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _writeLog('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
  };

  // Intercept all Dart asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    _writeLog('PlatformDispatcher Error: $error\n$stack');
    return true;
  };

  try {
    _writeLog('App launched. Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    _writeLog('Firebase initialized. Running app...');
  } catch (e, stack) {
    _writeLog('Firebase initialization error: $e\n$stack');
  }
  
  runApp(const ProviderScope(child: TrackifyApp()));
}
