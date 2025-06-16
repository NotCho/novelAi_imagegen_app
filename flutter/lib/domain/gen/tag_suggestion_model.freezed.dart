// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag_suggestion_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TagSuggestionModel {
  List<TagModel> get tags;

  /// Create a copy of TagSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TagSuggestionModelCopyWith<TagSuggestionModel> get copyWith =>
      _$TagSuggestionModelCopyWithImpl<TagSuggestionModel>(
          this as TagSuggestionModel, _$identity);

  /// Serializes this TagSuggestionModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TagSuggestionModel &&
            const DeepCollectionEquality().equals(other.tags, tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(tags));

  @override
  String toString() {
    return 'TagSuggestionModel(tags: $tags)';
  }
}

/// @nodoc
abstract mixin class $TagSuggestionModelCopyWith<$Res> {
  factory $TagSuggestionModelCopyWith(
          TagSuggestionModel value, $Res Function(TagSuggestionModel) _then) =
      _$TagSuggestionModelCopyWithImpl;
  @useResult
  $Res call({List<TagModel> tags});
}

/// @nodoc
class _$TagSuggestionModelCopyWithImpl<$Res>
    implements $TagSuggestionModelCopyWith<$Res> {
  _$TagSuggestionModelCopyWithImpl(this._self, this._then);

  final TagSuggestionModel _self;
  final $Res Function(TagSuggestionModel) _then;

  /// Create a copy of TagSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tags = null,
  }) {
    return _then(_self.copyWith(
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<TagModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TagSuggestionModel implements TagSuggestionModel {
  const _TagSuggestionModel({required final List<TagModel> tags})
      : _tags = tags;
  factory _TagSuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$TagSuggestionModelFromJson(json);

  final List<TagModel> _tags;
  @override
  List<TagModel> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Create a copy of TagSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TagSuggestionModelCopyWith<_TagSuggestionModel> get copyWith =>
      __$TagSuggestionModelCopyWithImpl<_TagSuggestionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TagSuggestionModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TagSuggestionModel &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_tags));

  @override
  String toString() {
    return 'TagSuggestionModel(tags: $tags)';
  }
}

/// @nodoc
abstract mixin class _$TagSuggestionModelCopyWith<$Res>
    implements $TagSuggestionModelCopyWith<$Res> {
  factory _$TagSuggestionModelCopyWith(
          _TagSuggestionModel value, $Res Function(_TagSuggestionModel) _then) =
      __$TagSuggestionModelCopyWithImpl;
  @override
  @useResult
  $Res call({List<TagModel> tags});
}

/// @nodoc
class __$TagSuggestionModelCopyWithImpl<$Res>
    implements _$TagSuggestionModelCopyWith<$Res> {
  __$TagSuggestionModelCopyWithImpl(this._self, this._then);

  final _TagSuggestionModel _self;
  final $Res Function(_TagSuggestionModel) _then;

  /// Create a copy of TagSuggestionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? tags = null,
  }) {
    return _then(_TagSuggestionModel(
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<TagModel>,
    ));
  }
}

/// @nodoc
mixin _$TagModel {
  String get tag;
  int get count;
  double get confidence;

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TagModelCopyWith<TagModel> get copyWith =>
      _$TagModelCopyWithImpl<TagModel>(this as TagModel, _$identity);

  /// Serializes this TagModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TagModel &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tag, count, confidence);

  @override
  String toString() {
    return 'TagModel(tag: $tag, count: $count, confidence: $confidence)';
  }
}

/// @nodoc
abstract mixin class $TagModelCopyWith<$Res> {
  factory $TagModelCopyWith(TagModel value, $Res Function(TagModel) _then) =
      _$TagModelCopyWithImpl;
  @useResult
  $Res call({String tag, int count, double confidence});
}

/// @nodoc
class _$TagModelCopyWithImpl<$Res> implements $TagModelCopyWith<$Res> {
  _$TagModelCopyWithImpl(this._self, this._then);

  final TagModel _self;
  final $Res Function(TagModel) _then;

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tag = null,
    Object? count = null,
    Object? confidence = null,
  }) {
    return _then(_self.copyWith(
      tag: null == tag
          ? _self.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TagModel implements TagModel {
  const _TagModel(
      {required this.tag, required this.count, required this.confidence});
  factory _TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  @override
  final String tag;
  @override
  final int count;
  @override
  final double confidence;

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TagModelCopyWith<_TagModel> get copyWith =>
      __$TagModelCopyWithImpl<_TagModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TagModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TagModel &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tag, count, confidence);

  @override
  String toString() {
    return 'TagModel(tag: $tag, count: $count, confidence: $confidence)';
  }
}

/// @nodoc
abstract mixin class _$TagModelCopyWith<$Res>
    implements $TagModelCopyWith<$Res> {
  factory _$TagModelCopyWith(_TagModel value, $Res Function(_TagModel) _then) =
      __$TagModelCopyWithImpl;
  @override
  @useResult
  $Res call({String tag, int count, double confidence});
}

/// @nodoc
class __$TagModelCopyWithImpl<$Res> implements _$TagModelCopyWith<$Res> {
  __$TagModelCopyWithImpl(this._self, this._then);

  final _TagModel _self;
  final $Res Function(_TagModel) _then;

  /// Create a copy of TagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? tag = null,
    Object? count = null,
    Object? confidence = null,
  }) {
    return _then(_TagModel(
      tag: null == tag
          ? _self.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      confidence: null == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
