class Business {
  final String id;
  final String userId;
  final String botId;
  final String? botToken;
  final String? telegramGroupId;
  final String status;
  final DateTime createdAt;

  const Business({
    required this.id,
    required this.userId,
    required this.botId,
    this.botToken,
    this.telegramGroupId,
    required this.status,
    required this.createdAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      botId: json['bot_id'] as String,
      botToken: json['bot_token'] as String?,
      telegramGroupId: json['telegram_group_id'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
