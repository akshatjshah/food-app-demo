// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'short_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShortItem _$ShortItemFromJson(Map<String, dynamic> json) => _ShortItem(
  id: json['id'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  videoUrl: json['video_url'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
);

Map<String, dynamic> _$ShortItemToJson(_ShortItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'video_url': instance.videoUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'likes_count': instance.likesCount,
      'views_count': instance.viewsCount,
      'is_liked': instance.isLiked,
    };
