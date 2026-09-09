import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';

class NotificationController extends GetxController {
  final _plugin = FlutterLocalNotificationsPlugin();
  var _ready = false;

  Future<void> init() async {
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _ready = true;
  }

  Future<void> showMessageNotification({
    required String senderName,
    required String roomName,
    required String body,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat messages',
      channelDescription: 'New messages while the app is in the background',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '$senderName · $roomName',
      body: body,
      notificationDetails: details,
      payload: jsonEncode({
        'route': AppRoutes.chat,
        'roomName': roomName,
      }),
    );
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      Get.toNamed(AppRoutes.chat);
      return;
    }

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      Get.toNamed(data['route'] as String? ?? AppRoutes.chat);
    } catch (_) {
      Get.toNamed(AppRoutes.chat);
    }
  }
}
