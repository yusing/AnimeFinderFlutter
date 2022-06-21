// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchHistoryEntry _$WatchHistoryEntryFromJson(Map<String, dynamic> json) =>
    WatchHistoryEntry(
      id: json['id'] as int,
      title: json['title'] as String,
      path: json['path'] as String,
      type: $enumDecode(_$WatchHistoryEntryTypeEnumMap, json['type']),
      duration: json['duration'] as int?,
      position: json['position'] as int?,
    );

Map<String, dynamic> _$WatchHistoryEntryToJson(WatchHistoryEntry instance) =>
    <String, dynamic>{
      'type': _$WatchHistoryEntryTypeEnumMap[instance.type],
      'id': instance.id,
      'title': instance.title,
      'path': instance.path,
      'duration': instance.duration,
      'position': instance.position,
    };

const _$WatchHistoryEntryTypeEnumMap = {
  WatchHistoryEntryType.video: 'video',
  WatchHistoryEntryType.image: 'image',
  WatchHistoryEntryType.audio: 'audio',
};

WatchHistories _$WatchHistoriesFromJson(Map<String, dynamic> json) =>
    WatchHistories(
      (json['value'] as List<dynamic>)
          .map((e) => WatchHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchHistoriesToJson(WatchHistories instance) =>
    <String, dynamic>{
      'value': instance.value,
    };
