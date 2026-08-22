import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import '../../features/task/domain/entities/task_entity.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click if needed
      },
    );
    _isInitialized = true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'trackify_reminders',
      'Trackify Reminders',
      channelDescription: 'Random reminders and task notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Auto notify the user about tasks remaining
  Future<void> notifyTasksRemaining(int remainingCount) async {
    await showNotification(
      id: 100,
      title: 'Task Reminder',
      body: 'you have $remainingCount task${remainingCount == 1 ? '' : 's'} remaining',
    );
  }

  /// Auto notify that a task is ending in 10 minutes
  Future<void> notifyTaskEndingSoon(String taskName) async {
    await showNotification(
      id: 101,
      title: 'Task Ending Soon',
      body: '10 min end $taskName task ,',
    );
  }

  /// Auto notify to not forget completing a task
  Future<void> notifyForgetTask(String taskName) async {
    await showNotification(
      id: 102,
      title: 'Task Pending',
      body: 'don\'t forgot to complte $taskName task',
    );
  }

  /// Triggers a random notification from the active/incomplete tasks
  Future<void> triggerRandomNotification(List<TaskEntity> incompleteTasks) async {
    if (incompleteTasks.isEmpty) return;

    final random = Random();
    final task = incompleteTasks[random.nextInt(incompleteTasks.length)];
    final type = random.nextInt(3);

    switch (type) {
      case 0:
        await notifyTasksRemaining(incompleteTasks.length);
        break;
      case 1:
        await notifyTaskEndingSoon(task.title);
        break;
      case 2:
        await notifyForgetTask(task.title);
        break;
    }
  }
}
