import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_suggestion_model.freezed.dart';

part 'tag_suggestion_model.g.dart';

@freezed
abstract class TagSuggestionModel with _$TagSuggestionModel {
  const factory TagSuggestionModel({
    required List<TagModel> tags,
  }) = _TagSuggestionModel;

  factory TagSuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$TagSuggestionModelFromJson(json);
}

@freezed
abstract class TagModel with _$TagModel {
  const factory TagModel({
    required String tag,
    required int count,
    required double confidence,
  }) = _TagModel;

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
}
