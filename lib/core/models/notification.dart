class NotificationsResponse {
  const NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final List<AppNotification> notifications;
  final int unreadCount;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'];
    if (json['success'] != true ||
        data is! Map<String, dynamic> ||
        meta is! Map<String, dynamic> ||
        data['notifications'] is! List) {
      throw const FormatException('Invalid notifications response.');
    }

    return NotificationsResponse(
      notifications: (data['notifications'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(),
      unreadCount: _intValue(data['unread_count']),
      currentPage: _intValue(meta['current_page']),
      lastPage: _intValue(meta['last_page']),
      perPage: _intValue(meta['per_page']),
      total: _intValue(meta['total']),
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final payload = _payloadMap(json['data']);
    final type = _stringValue(json['type']) ?? '';
    final rawTitle =
        _firstString(payload, const ['title', 'subject', 'heading']) ??
        _firstString(json, const ['title', 'subject']);
    final rawMessage =
        _firstString(payload, const [
          'message',
          'body',
          'description',
          'text',
        ]) ??
        _firstString(json, const ['message', 'body', 'description']);
    final readAt = _dateValue(json['read_at']);

    return AppNotification(
      id: _stringValue(json['id']) ?? '',
      type: type,
      title: rawTitle?.trim().isNotEmpty == true
          ? rawTitle!.trim()
          : _titleFromType(type),
      message: rawMessage?.trim().isNotEmpty == true
          ? rawMessage!.trim()
          : 'You have a new update.',
      readAt: readAt,
      createdAt: _dateValue(json['created_at']),
    );
  }

  static Map<String, dynamic> _payloadMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is List) {
      for (final item in value) {
        if (item is Map<String, dynamic>) return item;
      }
    }
    return const {};
  }

  static String? _firstString(Map<String, dynamic> values, List<String> keys) {
    for (final key in keys) {
      final value = _stringValue(values[key]);
      if (value?.trim().isNotEmpty == true) return value;
    }
    return null;
  }

  static String? _stringValue(dynamic value) =>
      value is String || value is num ? value.toString() : null;

  static DateTime? _dateValue(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;

  static String _titleFromType(String type) {
    final name = type.split(RegExp(r'[\\/.]')).last;
    final words = name
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
    if (words.isEmpty) return 'Notification';
    return words[0].toUpperCase() + words.substring(1);
  }
}

int _intValue(dynamic value) {
  if (value is int && value >= 0) return value;
  if (value is num && value >= 0) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
