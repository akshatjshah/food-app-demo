import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String title,
    required String body,
    String? type,
    @JsonKey(name: 'reference_id') String? referenceId,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationItem;

  /// Tolerant parser: accepts both snake_case (current API) and
  /// camelCase (legacy) keys so real backend payloads always load.
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    m['reference_id'] ??= m['referenceId'];
    m['is_read'] ??= m['isRead'];
    final created = m['created_at'] ?? m['createdAt'];
    if (created is int) {
      m['created_at'] =
          DateTime.fromMillisecondsSinceEpoch(created).toIso8601String();
    } else if (created != null) {
      m['created_at'] = created.toString();
    }
    return _$NotificationItemFromJson(m);
  }
}
