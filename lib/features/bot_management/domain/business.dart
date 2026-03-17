class Business {
  final String id;
  final String userId;
  final String botId;
  final String botToken;
  final String status;
  final String? telegramGroupId;
  final String? botSupabaseUrl;
  final String? botSupabaseAnonKey;
  final String? botBusinessId;

  Business({
    required this.id,
    required this.userId,
    required this.botId,
    required this.botToken,
    required this.status,
    this.telegramGroupId,
    this.botSupabaseUrl,
    this.botSupabaseAnonKey,
    this.botBusinessId,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      botId: json['bot_id'] as String,
      botToken: json['bot_token'] as String,
      status: json['status'] as String,
      telegramGroupId: json['telegram_group_id'] as String?,
      botSupabaseUrl: json['bot_supabase_url'] as String?,
      botSupabaseAnonKey: json['bot_supabase_anon_key'] as String?,
      botBusinessId: json['bot_business_id'] as String?,
    );
  }
}
