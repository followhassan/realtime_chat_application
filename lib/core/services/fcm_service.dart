import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // FCM displays the notification payload when app is backgrounded/killed.
}

class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? local,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _local = local ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  var _ready = false;

  Future<void> init() async {
    if (_ready) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteOpen);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _openChatFromData(initial.data);
    }

    _ready = true;
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Future<void> showLocalNotification({
    required String senderName,
    required String roomName,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat messages',
      channelDescription: 'New chat messages',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '$senderName · $roomName',
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode({'route': AppRoutes.chat}),
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ??
        '${message.data['senderName'] ?? 'Someone'} · ${message.data['roomName'] ?? 'Room'}';
    final body = notification?.body ?? message.data['body'] ?? '';
    if (body.isEmpty) return;
    await showLocalNotification(
      senderName: title,
      roomName: '',
      body: body,
    );
  }

  void _onRemoteOpen(RemoteMessage message) => _openChatFromData(message.data);

  void _onLocalTap(NotificationResponse response) {
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

  void _openChatFromData(Map<String, dynamic> data) {
    Get.toNamed(AppRoutes.chat);
  }
}
