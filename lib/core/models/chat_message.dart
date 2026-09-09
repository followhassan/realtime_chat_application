import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageKind { text, system }

enum DeliveryStatus { sending, sent, delivered }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    required this.clientId,
    this.kind = MessageKind.text,
    this.isMine = false,
    this.deliveryStatus = DeliveryStatus.sent,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final String clientId;
  final MessageKind kind;
  final bool isMine;
  final DeliveryStatus deliveryStatus;

  bool get isSystem => kind == MessageKind.system;

  factory ChatMessage.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String currentUserId,
  }) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    final type = data['type'] as String? ?? 'text';
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now(),
      clientId: data['clientId'] as String? ?? doc.id,
      kind: type == 'system' ? MessageKind.system : MessageKind.text,
      isMine: (data['senderId'] as String?) == currentUserId,
      deliveryStatus: DeliveryStatus.delivered,
    );
  }

  ChatMessage copyWith({
    String? id,
    DeliveryStatus? deliveryStatus,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId,
      senderName: senderName,
      body: body,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId,
      kind: kind,
      isMine: isMine,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
