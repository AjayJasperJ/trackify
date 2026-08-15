import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _writeLog(
    'APP_STARTED_NO_FIREBASE\nOS: ${Platform.operatingSystem}\nOSVersion: ${Platform.operatingSystemVersion}\nDart: ${Platform.version}',
  );

  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Trackify Test')),
        body: const Center(child: Text('No Firebase build')),
      ),
    ),
  );
}