// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_suggestion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagSuggestionModel _$TagSuggestionModelFromJson(Map<String, dynamic> json) =>
    _TagSuggestionModel(
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TagSuggestionModelToJson(_TagSuggestionModel instance) =>
    <String, dynamic>{
      'tags': instance.tags,
    };

_TagModel _$TagModelFromJson(Map<String, dynamic> json) => _TagModel(
      tag: json['tag'] as String,
      count: (json['count'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$TagModelToJson(_TagModel instance) => <String, dynamic>{
      'tag': instance.tag,
      'count': instance.count,
      'confidence': instance.confidence,
    };
