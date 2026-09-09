enum MessageKind { text, system }

enum DeliveryStatus { sending, sent, delivered }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    this.kind = MessageKind.text,
    this.isMine = false,
    this.deliveryStatus = DeliveryStatus.sent,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final MessageKind kind;
  final bool isMine;
  final DeliveryStatus deliveryStatus;

  ChatMessage copyWith({
    DeliveryStatus? deliveryStatus,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      body: body,
      createdAt: createdAt,
      kind: kind,
      isMine: isMine,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}
