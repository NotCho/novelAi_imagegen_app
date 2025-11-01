// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diffusion_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiffusionModel implements DiagnosticableTreeMixin {
  String get input;
  String get model;
  String get action;
  Parameters get parameters;

  /// Create a copy of DiffusionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DiffusionModelCopyWith<DiffusionModel> get copyWith =>
      _$DiffusionModelCopyWithImpl<DiffusionModel>(
          this as DiffusionModel, _$identity);

  /// Serializes this DiffusionModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DiffusionModel'))
      ..add(DiagnosticsProperty('input', input))
      ..add(DiagnosticsProperty('model', model))
      ..add(DiagnosticsProperty('action', action))
      ..add(DiagnosticsProperty('parameters', parameters));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DiffusionModel &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.parameters, parameters) ||
                other.parameters == parameters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, input, model, action, parameters);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DiffusionModel(input: $input, model: $model, action: $action, parameters: $parameters)';
  }
}

/// @nodoc
abstract mixin class $DiffusionModelCopyWith<$Res> {
  factory $DiffusionModelCopyWith(
          DiffusionModel value, $Res Function(DiffusionModel) _then) =
      _$DiffusionModelCopyWithImpl;
  @useResult
  $Res call({String input, String model, String action, Parameters parameters});

  $ParametersCopyWith<$Res> get parameters;
}

/// @nodoc
class _$DiffusionModelCopyWithImpl<$Res>
    implements $DiffusionModelCopyWith<$Res> {
  _$DiffusionModelCopyWithImpl(this._self, this._then);

  final DiffusionModel _self;
  final $Res Function(DiffusionModel) _then;

  /// Create a copy of DiffusionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? input = null,
    Object? model = null,
    Object? action = null,
    Object? parameters = null,
  }) {
    return _then(_self.copyWith(
      input: null == input
          ? _self.input
          : input // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _self.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: null == parameters
          ? _self.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Parameters,
    ));
  }

  /// Create a copy of DiffusionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParametersCopyWith<$Res> get parameters {
    return $ParametersCopyWith<$Res>(_self.parameters, (value) {
      return _then(_self.copyWith(parameters: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _DiffusionModel with DiagnosticableTreeMixin implements DiffusionModel {
  const _DiffusionModel(
      {required this.input,
      required this.model,
      required this.action,
      required this.parameters});
  factory _DiffusionModel.fromJson(Map<String, dynamic> json) =>
      _$DiffusionModelFromJson(json);

  @override
  final String input;
  @override
  final String model;
  @override
  final String action;
  @override
  final Parameters parameters;

  /// Create a copy of DiffusionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DiffusionModelCopyWith<_DiffusionModel> get copyWith =>
      __$DiffusionModelCopyWithImpl<_DiffusionModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DiffusionModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DiffusionModel'))
      ..add(DiagnosticsProperty('input', input))
      ..add(DiagnosticsProperty('model', model))
      ..add(DiagnosticsProperty('action', action))
      ..add(DiagnosticsProperty('parameters', parameters));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DiffusionModel &&
            (identical(other.input, input) || other.input == input) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.parameters, parameters) ||
                other.parameters == parameters));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, input, model, action, parameters);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DiffusionModel(input: $input, model: $model, action: $action, parameters: $parameters)';
  }
}

/// @nodoc
abstract mixin class _$DiffusionModelCopyWith<$Res>
    implements $DiffusionModelCopyWith<$Res> {
  factory _$DiffusionModelCopyWith(
          _DiffusionModel value, $Res Function(_DiffusionModel) _then) =
      __$DiffusionModelCopyWithImpl;
  @override
  @useResult
  $Res call({String input, String model, String action, Parameters parameters});

  @override
  $ParametersCopyWith<$Res> get parameters;
}

/// @nodoc
class __$DiffusionModelCopyWithImpl<$Res>
    implements _$DiffusionModelCopyWith<$Res> {
  __$DiffusionModelCopyWithImpl(this._self, this._then);

  final _DiffusionModel _self;
  final $Res Function(_DiffusionModel) _then;

  /// Create a copy of DiffusionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? input = null,
    Object? model = null,
    Object? action = null,
    Object? parameters = null,
  }) {
    return _then(_DiffusionModel(
      input: null == input
          ? _self.input
          : input // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _self.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      parameters: null == parameters
          ? _self.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Parameters,
    ));
  }

  /// Create a copy of DiffusionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParametersCopyWith<$Res> get parameters {
    return $ParametersCopyWith<$Res>(_self.parameters, (value) {
      return _then(_self.copyWith(parameters: value));
    });
  }
}

/// @nodoc
mixin _$Parameters implements DiagnosticableTreeMixin {
  int get params_version;
  int get width;
  int get height;
  double get scale;
  String get sampler;
  int get steps;
  int get n_samples;
  int get ucPreset;
  bool get qualityToggle;
  bool get autoSmea;
  bool get dynamic_thresholding;
  int get controlnet_strength;
  bool get legacy;
  bool get add_original_image;
  double get cfg_rescale;
  String get noise_schedule;
  bool get legacy_v3_extend;
  int? get skip_cfg_above_sigma;
  bool get use_coords;
  bool get legacy_uc;
  bool get normalize_reference_strength_multiple;
  V4Prompt get v4_prompt;
  V4NegativePrompt get v4_negative_prompt;
  int get seed;
  List<CharacterPrompt> get characterPrompts;
  List<String> get reference_image_multiple;
  List<double> get reference_strength_multiple;
  String get negative_prompt;
  bool get deliberate_euler_ancestral_bug;
  bool get prefer_brownian;
  List<DirectorReferenceDescription> get director_reference_descriptions;
  List<String> get director_reference_images;
  List<int> get director_reference_information_extracted;
  List<double> get director_reference_secondary_strength_values;
  List<double> get director_reference_strength_values;

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ParametersCopyWith<Parameters> get copyWith =>
      _$ParametersCopyWithImpl<Parameters>(this as Parameters, _$identity);

  /// Serializes this Parameters to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Parameters'))
      ..add(DiagnosticsProperty('params_version', params_version))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('scale', scale))
      ..add(DiagnosticsProperty('sampler', sampler))
      ..add(DiagnosticsProperty('steps', steps))
      ..add(DiagnosticsProperty('n_samples', n_samples))
      ..add(DiagnosticsProperty('ucPreset', ucPreset))
      ..add(DiagnosticsProperty('qualityToggle', qualityToggle))
      ..add(DiagnosticsProperty('autoSmea', autoSmea))
      ..add(DiagnosticsProperty('dynamic_thresholding', dynamic_thresholding))
      ..add(DiagnosticsProperty('controlnet_strength', controlnet_strength))
      ..add(DiagnosticsProperty('legacy', legacy))
      ..add(DiagnosticsProperty('add_original_image', add_original_image))
      ..add(DiagnosticsProperty('cfg_rescale', cfg_rescale))
      ..add(DiagnosticsProperty('noise_schedule', noise_schedule))
      ..add(DiagnosticsProperty('legacy_v3_extend', legacy_v3_extend))
      ..add(DiagnosticsProperty('skip_cfg_above_sigma', skip_cfg_above_sigma))
      ..add(DiagnosticsProperty('use_coords', use_coords))
      ..add(DiagnosticsProperty('legacy_uc', legacy_uc))
      ..add(DiagnosticsProperty('normalize_reference_strength_multiple',
          normalize_reference_strength_multiple))
      ..add(DiagnosticsProperty('v4_prompt', v4_prompt))
      ..add(DiagnosticsProperty('v4_negative_prompt', v4_negative_prompt))
      ..add(DiagnosticsProperty('seed', seed))
      ..add(DiagnosticsProperty('characterPrompts', characterPrompts))
      ..add(DiagnosticsProperty(
          'reference_image_multiple', reference_image_multiple))
      ..add(DiagnosticsProperty(
          'reference_strength_multiple', reference_strength_multiple))
      ..add(DiagnosticsProperty('negative_prompt', negative_prompt))
      ..add(DiagnosticsProperty(
          'deliberate_euler_ancestral_bug', deliberate_euler_ancestral_bug))
      ..add(DiagnosticsProperty('prefer_brownian', prefer_brownian))
      ..add(DiagnosticsProperty(
          'director_reference_descriptions', director_reference_descriptions))
      ..add(DiagnosticsProperty(
          'director_reference_images', director_reference_images))
      ..add(DiagnosticsProperty('director_reference_information_extracted',
          director_reference_information_extracted))
      ..add(DiagnosticsProperty('director_reference_secondary_strength_values',
          director_reference_secondary_strength_values))
      ..add(DiagnosticsProperty('director_reference_strength_values',
          director_reference_strength_values));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Parameters &&
            (identical(other.params_version, params_version) ||
                other.params_version == params_version) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.sampler, sampler) || other.sampler == sampler) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.n_samples, n_samples) ||
                other.n_samples == n_samples) &&
            (identical(other.ucPreset, ucPreset) ||
                other.ucPreset == ucPreset) &&
            (identical(other.qualityToggle, qualityToggle) ||
                other.qualityToggle == qualityToggle) &&
            (identical(other.autoSmea, autoSmea) ||
                other.autoSmea == autoSmea) &&
            (identical(other.dynamic_thresholding, dynamic_thresholding) ||
                other.dynamic_thresholding == dynamic_thresholding) &&
            (identical(other.controlnet_strength, controlnet_strength) ||
                other.controlnet_strength == controlnet_strength) &&
            (identical(other.legacy, legacy) || other.legacy == legacy) &&
            (identical(other.add_original_image, add_original_image) ||
                other.add_original_image == add_original_image) &&
            (identical(other.cfg_rescale, cfg_rescale) ||
                other.cfg_rescale == cfg_rescale) &&
            (identical(other.noise_schedule, noise_schedule) ||
                other.noise_schedule == noise_schedule) &&
            (identical(other.legacy_v3_extend, legacy_v3_extend) ||
                other.legacy_v3_extend == legacy_v3_extend) &&
            (identical(other.skip_cfg_above_sigma, skip_cfg_above_sigma) ||
                other.skip_cfg_above_sigma == skip_cfg_above_sigma) &&
            (identical(other.use_coords, use_coords) ||
                other.use_coords == use_coords) &&
            (identical(other.legacy_uc, legacy_uc) ||
                other.legacy_uc == legacy_uc) &&
            (identical(other.normalize_reference_strength_multiple, normalize_reference_strength_multiple) ||
                other.normalize_reference_strength_multiple ==
                    normalize_reference_strength_multiple) &&
            (identical(other.v4_prompt, v4_prompt) ||
                other.v4_prompt == v4_prompt) &&
            (identical(other.v4_negative_prompt, v4_negative_prompt) ||
                other.v4_negative_prompt == v4_negative_prompt) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            const DeepCollectionEquality()
                .equals(other.characterPrompts, characterPrompts) &&
            const DeepCollectionEquality().equals(
                other.reference_image_multiple, reference_image_multiple) &&
            const DeepCollectionEquality().equals(
                other.reference_strength_multiple,
                reference_strength_multiple) &&
            (identical(other.negative_prompt, negative_prompt) ||
                other.negative_prompt == negative_prompt) &&
            (identical(other.deliberate_euler_ancestral_bug, deliberate_euler_ancestral_bug) ||
                other.deliberate_euler_ancestral_bug ==
                    deliberate_euler_ancestral_bug) &&
            (identical(other.prefer_brownian, prefer_brownian) ||
                other.prefer_brownian == prefer_brownian) &&
            const DeepCollectionEquality().equals(
                other.director_reference_descriptions,
                director_reference_descriptions) &&
            const DeepCollectionEquality().equals(
                other.director_reference_images, director_reference_images) &&
            const DeepCollectionEquality().equals(
                other.director_reference_information_extracted,
                director_reference_information_extracted) &&
            const DeepCollectionEquality().equals(
                other.director_reference_secondary_strength_values,
                director_reference_secondary_strength_values) &&
            const DeepCollectionEquality().equals(
                other.director_reference_strength_values, director_reference_strength_values));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        params_version,
        width,
        height,
        scale,
        sampler,
        steps,
        n_samples,
        ucPreset,
        qualityToggle,
        autoSmea,
        dynamic_thresholding,
        controlnet_strength,
        legacy,
        add_original_image,
        cfg_rescale,
        noise_schedule,
        legacy_v3_extend,
        skip_cfg_above_sigma,
        use_coords,
        legacy_uc,
        normalize_reference_strength_multiple,
        v4_prompt,
        v4_negative_prompt,
        seed,
        const DeepCollectionEquality().hash(characterPrompts),
        const DeepCollectionEquality().hash(reference_image_multiple),
        const DeepCollectionEquality().hash(reference_strength_multiple),
        negative_prompt,
        deliberate_euler_ancestral_bug,
        prefer_brownian,
        const DeepCollectionEquality().hash(director_reference_descriptions),
        const DeepCollectionEquality().hash(director_reference_images),
        const DeepCollectionEquality()
            .hash(director_reference_information_extracted),
        const DeepCollectionEquality()
            .hash(director_reference_secondary_strength_values),
        const DeepCollectionEquality().hash(director_reference_strength_values)
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Parameters(params_version: $params_version, width: $width, height: $height, scale: $scale, sampler: $sampler, steps: $steps, n_samples: $n_samples, ucPreset: $ucPreset, qualityToggle: $qualityToggle, autoSmea: $autoSmea, dynamic_thresholding: $dynamic_thresholding, controlnet_strength: $controlnet_strength, legacy: $legacy, add_original_image: $add_original_image, cfg_rescale: $cfg_rescale, noise_schedule: $noise_schedule, legacy_v3_extend: $legacy_v3_extend, skip_cfg_above_sigma: $skip_cfg_above_sigma, use_coords: $use_coords, legacy_uc: $legacy_uc, normalize_reference_strength_multiple: $normalize_reference_strength_multiple, v4_prompt: $v4_prompt, v4_negative_prompt: $v4_negative_prompt, seed: $seed, characterPrompts: $characterPrompts, reference_image_multiple: $reference_image_multiple, reference_strength_multiple: $reference_strength_multiple, negative_prompt: $negative_prompt, deliberate_euler_ancestral_bug: $deliberate_euler_ancestral_bug, prefer_brownian: $prefer_brownian, director_reference_descriptions: $director_reference_descriptions, director_reference_images: $director_reference_images, director_reference_information_extracted: $director_reference_information_extracted, director_reference_secondary_strength_values: $director_reference_secondary_strength_values, director_reference_strength_values: $director_reference_strength_values)';
  }
}

/// @nodoc
abstract mixin class $ParametersCopyWith<$Res> {
  factory $ParametersCopyWith(
          Parameters value, $Res Function(Parameters) _then) =
      _$ParametersCopyWithImpl;
  @useResult
  $Res call(
      {int params_version,
      int width,
      int height,
      double scale,
      String sampler,
      int steps,
      int n_samples,
      int ucPreset,
      bool qualityToggle,
      bool autoSmea,
      bool dynamic_thresholding,
      int controlnet_strength,
      bool legacy,
      bool add_original_image,
      double cfg_rescale,
      String noise_schedule,
      bool legacy_v3_extend,
      int? skip_cfg_above_sigma,
      bool use_coords,
      bool legacy_uc,
      bool normalize_reference_strength_multiple,
      V4Prompt v4_prompt,
      V4NegativePrompt v4_negative_prompt,
      int seed,
      List<CharacterPrompt> characterPrompts,
      List<String> reference_image_multiple,
      List<double> reference_strength_multiple,
      String negative_prompt,
      bool deliberate_euler_ancestral_bug,
      bool prefer_brownian,
      List<DirectorReferenceDescription> director_reference_descriptions,
      List<String> director_reference_images,
      List<int> director_reference_information_extracted,
      List<double> director_reference_secondary_strength_values,
      List<double> director_reference_strength_values});

  $V4PromptCopyWith<$Res> get v4_prompt;
  $V4NegativePromptCopyWith<$Res> get v4_negative_prompt;
}

/// @nodoc
class _$ParametersCopyWithImpl<$Res> implements $ParametersCopyWith<$Res> {
  _$ParametersCopyWithImpl(this._self, this._then);

  final Parameters _self;
  final $Res Function(Parameters) _then;

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? params_version = null,
    Object? width = null,
    Object? height = null,
    Object? scale = null,
    Object? sampler = null,
    Object? steps = null,
    Object? n_samples = null,
    Object? ucPreset = null,
    Object? qualityToggle = null,
    Object? autoSmea = null,
    Object? dynamic_thresholding = null,
    Object? controlnet_strength = null,
    Object? legacy = null,
    Object? add_original_image = null,
    Object? cfg_rescale = null,
    Object? noise_schedule = null,
    Object? legacy_v3_extend = null,
    Object? skip_cfg_above_sigma = freezed,
    Object? use_coords = null,
    Object? legacy_uc = null,
    Object? normalize_reference_strength_multiple = null,
    Object? v4_prompt = null,
    Object? v4_negative_prompt = null,
    Object? seed = null,
    Object? characterPrompts = null,
    Object? reference_image_multiple = null,
    Object? reference_strength_multiple = null,
    Object? negative_prompt = null,
    Object? deliberate_euler_ancestral_bug = null,
    Object? prefer_brownian = null,
    Object? director_reference_descriptions = null,
    Object? director_reference_images = null,
    Object? director_reference_information_extracted = null,
    Object? director_reference_secondary_strength_values = null,
    Object? director_reference_strength_values = null,
  }) {
    return _then(_self.copyWith(
      params_version: null == params_version
          ? _self.params_version
          : params_version // ignore: cast_nullable_to_non_nullable
              as int,
      width: null == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      scale: null == scale
          ? _self.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
      sampler: null == sampler
          ? _self.sampler
          : sampler // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _self.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      n_samples: null == n_samples
          ? _self.n_samples
          : n_samples // ignore: cast_nullable_to_non_nullable
              as int,
      ucPreset: null == ucPreset
          ? _self.ucPreset
          : ucPreset // ignore: cast_nullable_to_non_nullable
              as int,
      qualityToggle: null == qualityToggle
          ? _self.qualityToggle
          : qualityToggle // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSmea: null == autoSmea
          ? _self.autoSmea
          : autoSmea // ignore: cast_nullable_to_non_nullable
              as bool,
      dynamic_thresholding: null == dynamic_thresholding
          ? _self.dynamic_thresholding
          : dynamic_thresholding // ignore: cast_nullable_to_non_nullable
              as bool,
      controlnet_strength: null == controlnet_strength
          ? _self.controlnet_strength
          : controlnet_strength // ignore: cast_nullable_to_non_nullable
              as int,
      legacy: null == legacy
          ? _self.legacy
          : legacy // ignore: cast_nullable_to_non_nullable
              as bool,
      add_original_image: null == add_original_image
          ? _self.add_original_image
          : add_original_image // ignore: cast_nullable_to_non_nullable
              as bool,
      cfg_rescale: null == cfg_rescale
          ? _self.cfg_rescale
          : cfg_rescale // ignore: cast_nullable_to_non_nullable
              as double,
      noise_schedule: null == noise_schedule
          ? _self.noise_schedule
          : noise_schedule // ignore: cast_nullable_to_non_nullable
              as String,
      legacy_v3_extend: null == legacy_v3_extend
          ? _self.legacy_v3_extend
          : legacy_v3_extend // ignore: cast_nullable_to_non_nullable
              as bool,
      skip_cfg_above_sigma: freezed == skip_cfg_above_sigma
          ? _self.skip_cfg_above_sigma
          : skip_cfg_above_sigma // ignore: cast_nullable_to_non_nullable
              as int?,
      use_coords: null == use_coords
          ? _self.use_coords
          : use_coords // ignore: cast_nullable_to_non_nullable
              as bool,
      legacy_uc: null == legacy_uc
          ? _self.legacy_uc
          : legacy_uc // ignore: cast_nullable_to_non_nullable
              as bool,
      normalize_reference_strength_multiple: null ==
              normalize_reference_strength_multiple
          ? _self.normalize_reference_strength_multiple
          : normalize_reference_strength_multiple // ignore: cast_nullable_to_non_nullable
              as bool,
      v4_prompt: null == v4_prompt
          ? _self.v4_prompt
          : v4_prompt // ignore: cast_nullable_to_non_nullable
              as V4Prompt,
      v4_negative_prompt: null == v4_negative_prompt
          ? _self.v4_negative_prompt
          : v4_negative_prompt // ignore: cast_nullable_to_non_nullable
              as V4NegativePrompt,
      seed: null == seed
          ? _self.seed
          : seed // ignore: cast_nullable_to_non_nullable
              as int,
      characterPrompts: null == characterPrompts
          ? _self.characterPrompts
          : characterPrompts // ignore: cast_nullable_to_non_nullable
              as List<CharacterPrompt>,
      reference_image_multiple: null == reference_image_multiple
          ? _self.reference_image_multiple
          : reference_image_multiple // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reference_strength_multiple: null == reference_strength_multiple
          ? _self.reference_strength_multiple
          : reference_strength_multiple // ignore: cast_nullable_to_non_nullable
              as List<double>,
      negative_prompt: null == negative_prompt
          ? _self.negative_prompt
          : negative_prompt // ignore: cast_nullable_to_non_nullable
              as String,
      deliberate_euler_ancestral_bug: null == deliberate_euler_ancestral_bug
          ? _self.deliberate_euler_ancestral_bug
          : deliberate_euler_ancestral_bug // ignore: cast_nullable_to_non_nullable
              as bool,
      prefer_brownian: null == prefer_brownian
          ? _self.prefer_brownian
          : prefer_brownian // ignore: cast_nullable_to_non_nullable
              as bool,
      director_reference_descriptions: null == director_reference_descriptions
          ? _self.director_reference_descriptions
          : director_reference_descriptions // ignore: cast_nullable_to_non_nullable
              as List<DirectorReferenceDescription>,
      director_reference_images: null == director_reference_images
          ? _self.director_reference_images
          : director_reference_images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      director_reference_information_extracted: null ==
              director_reference_information_extracted
          ? _self.director_reference_information_extracted
          : director_reference_information_extracted // ignore: cast_nullable_to_non_nullable
              as List<int>,
      director_reference_secondary_strength_values: null ==
              director_reference_secondary_strength_values
          ? _self.director_reference_secondary_strength_values
          : director_reference_secondary_strength_values // ignore: cast_nullable_to_non_nullable
              as List<double>,
      director_reference_strength_values: null ==
              director_reference_strength_values
          ? _self.director_reference_strength_values
          : director_reference_strength_values // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $V4PromptCopyWith<$Res> get v4_prompt {
    return $V4PromptCopyWith<$Res>(_self.v4_prompt, (value) {
      return _then(_self.copyWith(v4_prompt: value));
    });
  }

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $V4NegativePromptCopyWith<$Res> get v4_negative_prompt {
    return $V4NegativePromptCopyWith<$Res>(_self.v4_negative_prompt, (value) {
      return _then(_self.copyWith(v4_negative_prompt: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _Parameters with DiagnosticableTreeMixin implements Parameters {
  const _Parameters(
      {required this.params_version,
      required this.width,
      required this.height,
      required this.scale,
      required this.sampler,
      required this.steps,
      required this.n_samples,
      required this.ucPreset,
      required this.qualityToggle,
      required this.autoSmea,
      required this.dynamic_thresholding,
      required this.controlnet_strength,
      required this.legacy,
      required this.add_original_image,
      required this.cfg_rescale,
      required this.noise_schedule,
      required this.legacy_v3_extend,
      this.skip_cfg_above_sigma,
      required this.use_coords,
      required this.legacy_uc,
      required this.normalize_reference_strength_multiple,
      required this.v4_prompt,
      required this.v4_negative_prompt,
      required this.seed,
      required final List<CharacterPrompt> characterPrompts,
      final List<String> reference_image_multiple = const [],
      final List<double> reference_strength_multiple = const [],
      required this.negative_prompt,
      required this.deliberate_euler_ancestral_bug,
      required this.prefer_brownian,
      final List<DirectorReferenceDescription> director_reference_descriptions =
          const [],
      final List<String> director_reference_images = const [],
      final List<int> director_reference_information_extracted = const [],
      final List<double> director_reference_secondary_strength_values =
          const [],
      final List<double> director_reference_strength_values = const []})
      : _characterPrompts = characterPrompts,
        _reference_image_multiple = reference_image_multiple,
        _reference_strength_multiple = reference_strength_multiple,
        _director_reference_descriptions = director_reference_descriptions,
        _director_reference_images = director_reference_images,
        _director_reference_information_extracted =
            director_reference_information_extracted,
        _director_reference_secondary_strength_values =
            director_reference_secondary_strength_values,
        _director_reference_strength_values =
            director_reference_strength_values;
  factory _Parameters.fromJson(Map<String, dynamic> json) =>
      _$ParametersFromJson(json);

  @override
  final int params_version;
  @override
  final int width;
  @override
  final int height;
  @override
  final double scale;
  @override
  final String sampler;
  @override
  final int steps;
  @override
  final int n_samples;
  @override
  final int ucPreset;
  @override
  final bool qualityToggle;
  @override
  final bool autoSmea;
  @override
  final bool dynamic_thresholding;
  @override
  final int controlnet_strength;
  @override
  final bool legacy;
  @override
  final bool add_original_image;
  @override
  final double cfg_rescale;
  @override
  final String noise_schedule;
  @override
  final bool legacy_v3_extend;
  @override
  final int? skip_cfg_above_sigma;
  @override
  final bool use_coords;
  @override
  final bool legacy_uc;
  @override
  final bool normalize_reference_strength_multiple;
  @override
  final V4Prompt v4_prompt;
  @override
  final V4NegativePrompt v4_negative_prompt;
  @override
  final int seed;
  final List<CharacterPrompt> _characterPrompts;
  @override
  List<CharacterPrompt> get characterPrompts {
    if (_characterPrompts is EqualUnmodifiableListView)
      return _characterPrompts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_characterPrompts);
  }

  final List<String> _reference_image_multiple;
  @override
  @JsonKey()
  List<String> get reference_image_multiple {
    if (_reference_image_multiple is EqualUnmodifiableListView)
      return _reference_image_multiple;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reference_image_multiple);
  }

  final List<double> _reference_strength_multiple;
  @override
  @JsonKey()
  List<double> get reference_strength_multiple {
    if (_reference_strength_multiple is EqualUnmodifiableListView)
      return _reference_strength_multiple;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reference_strength_multiple);
  }

  @override
  final String negative_prompt;
  @override
  final bool deliberate_euler_ancestral_bug;
  @override
  final bool prefer_brownian;
  final List<DirectorReferenceDescription> _director_reference_descriptions;
  @override
  @JsonKey()
  List<DirectorReferenceDescription> get director_reference_descriptions {
    if (_director_reference_descriptions is EqualUnmodifiableListView)
      return _director_reference_descriptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_director_reference_descriptions);
  }

  final List<String> _director_reference_images;
  @override
  @JsonKey()
  List<String> get director_reference_images {
    if (_director_reference_images is EqualUnmodifiableListView)
      return _director_reference_images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_director_reference_images);
  }

  final List<int> _director_reference_information_extracted;
  @override
  @JsonKey()
  List<int> get director_reference_information_extracted {
    if (_director_reference_information_extracted is EqualUnmodifiableListView)
      return _director_reference_information_extracted;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_director_reference_information_extracted);
  }

  final List<double> _director_reference_secondary_strength_values;
  @override
  @JsonKey()
  List<double> get director_reference_secondary_strength_values {
    if (_director_reference_secondary_strength_values
        is EqualUnmodifiableListView)
      return _director_reference_secondary_strength_values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(
        _director_reference_secondary_strength_values);
  }

  final List<double> _director_reference_strength_values;
  @override
  @JsonKey()
  List<double> get director_reference_strength_values {
    if (_director_reference_strength_values is EqualUnmodifiableListView)
      return _director_reference_strength_values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_director_reference_strength_values);
  }

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ParametersCopyWith<_Parameters> get copyWith =>
      __$ParametersCopyWithImpl<_Parameters>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ParametersToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Parameters'))
      ..add(DiagnosticsProperty('params_version', params_version))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('scale', scale))
      ..add(DiagnosticsProperty('sampler', sampler))
      ..add(DiagnosticsProperty('steps', steps))
      ..add(DiagnosticsProperty('n_samples', n_samples))
      ..add(DiagnosticsProperty('ucPreset', ucPreset))
      ..add(DiagnosticsProperty('qualityToggle', qualityToggle))
      ..add(DiagnosticsProperty('autoSmea', autoSmea))
      ..add(DiagnosticsProperty('dynamic_thresholding', dynamic_thresholding))
      ..add(DiagnosticsProperty('controlnet_strength', controlnet_strength))
      ..add(DiagnosticsProperty('legacy', legacy))
      ..add(DiagnosticsProperty('add_original_image', add_original_image))
      ..add(DiagnosticsProperty('cfg_rescale', cfg_rescale))
      ..add(DiagnosticsProperty('noise_schedule', noise_schedule))
      ..add(DiagnosticsProperty('legacy_v3_extend', legacy_v3_extend))
      ..add(DiagnosticsProperty('skip_cfg_above_sigma', skip_cfg_above_sigma))
      ..add(DiagnosticsProperty('use_coords', use_coords))
      ..add(DiagnosticsProperty('legacy_uc', legacy_uc))
      ..add(DiagnosticsProperty('normalize_reference_strength_multiple',
          normalize_reference_strength_multiple))
      ..add(DiagnosticsProperty('v4_prompt', v4_prompt))
      ..add(DiagnosticsProperty('v4_negative_prompt', v4_negative_prompt))
      ..add(DiagnosticsProperty('seed', seed))
      ..add(DiagnosticsProperty('characterPrompts', characterPrompts))
      ..add(DiagnosticsProperty(
          'reference_image_multiple', reference_image_multiple))
      ..add(DiagnosticsProperty(
          'reference_strength_multiple', reference_strength_multiple))
      ..add(DiagnosticsProperty('negative_prompt', negative_prompt))
      ..add(DiagnosticsProperty(
          'deliberate_euler_ancestral_bug', deliberate_euler_ancestral_bug))
      ..add(DiagnosticsProperty('prefer_brownian', prefer_brownian))
      ..add(DiagnosticsProperty(
          'director_reference_descriptions', director_reference_descriptions))
      ..add(DiagnosticsProperty(
          'director_reference_images', director_reference_images))
      ..add(DiagnosticsProperty('director_reference_information_extracted',
          director_reference_information_extracted))
      ..add(DiagnosticsProperty('director_reference_secondary_strength_values',
          director_reference_secondary_strength_values))
      ..add(DiagnosticsProperty('director_reference_strength_values',
          director_reference_strength_values));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Parameters &&
            (identical(other.params_version, params_version) ||
                other.params_version == params_version) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.sampler, sampler) || other.sampler == sampler) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.n_samples, n_samples) ||
                other.n_samples == n_samples) &&
            (identical(other.ucPreset, ucPreset) ||
                other.ucPreset == ucPreset) &&
            (identical(other.qualityToggle, qualityToggle) ||
                other.qualityToggle == qualityToggle) &&
            (identical(other.autoSmea, autoSmea) ||
                other.autoSmea == autoSmea) &&
            (identical(other.dynamic_thresholding, dynamic_thresholding) ||
                other.dynamic_thresholding == dynamic_thresholding) &&
            (identical(other.controlnet_strength, controlnet_strength) ||
                other.controlnet_strength == controlnet_strength) &&
            (identical(other.legacy, legacy) || other.legacy == legacy) &&
            (identical(other.add_original_image, add_original_image) ||
                other.add_original_image == add_original_image) &&
            (identical(other.cfg_rescale, cfg_rescale) ||
                other.cfg_rescale == cfg_rescale) &&
            (identical(other.noise_schedule, noise_schedule) ||
                other.noise_schedule == noise_schedule) &&
            (identical(other.legacy_v3_extend, legacy_v3_extend) ||
                other.legacy_v3_extend == legacy_v3_extend) &&
            (identical(other.skip_cfg_above_sigma, skip_cfg_above_sigma) ||
                other.skip_cfg_above_sigma == skip_cfg_above_sigma) &&
            (identical(other.use_coords, use_coords) ||
                other.use_coords == use_coords) &&
            (identical(other.legacy_uc, legacy_uc) ||
                other.legacy_uc == legacy_uc) &&
            (identical(other.normalize_reference_strength_multiple, normalize_reference_strength_multiple) ||
                other.normalize_reference_strength_multiple ==
                    normalize_reference_strength_multiple) &&
            (identical(other.v4_prompt, v4_prompt) ||
                other.v4_prompt == v4_prompt) &&
            (identical(other.v4_negative_prompt, v4_negative_prompt) ||
                other.v4_negative_prompt == v4_negative_prompt) &&
            (identical(other.seed, seed) || other.seed == seed) &&
            const DeepCollectionEquality()
                .equals(other._characterPrompts, _characterPrompts) &&
            const DeepCollectionEquality().equals(
                other._reference_image_multiple, _reference_image_multiple) &&
            const DeepCollectionEquality().equals(
                other._reference_strength_multiple,
                _reference_strength_multiple) &&
            (identical(other.negative_prompt, negative_prompt) ||
                other.negative_prompt == negative_prompt) &&
            (identical(other.deliberate_euler_ancestral_bug, deliberate_euler_ancestral_bug) ||
                other.deliberate_euler_ancestral_bug ==
                    deliberate_euler_ancestral_bug) &&
            (identical(other.prefer_brownian, prefer_brownian) ||
                other.prefer_brownian == prefer_brownian) &&
            const DeepCollectionEquality().equals(
                other._director_reference_descriptions,
                _director_reference_descriptions) &&
            const DeepCollectionEquality().equals(
                other._director_reference_images, _director_reference_images) &&
            const DeepCollectionEquality().equals(
                other._director_reference_information_extracted,
                _director_reference_information_extracted) &&
            const DeepCollectionEquality().equals(
                other._director_reference_secondary_strength_values,
                _director_reference_secondary_strength_values) &&
            const DeepCollectionEquality().equals(
                other._director_reference_strength_values, _director_reference_strength_values));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        params_version,
        width,
        height,
        scale,
        sampler,
        steps,
        n_samples,
        ucPreset,
        qualityToggle,
        autoSmea,
        dynamic_thresholding,
        controlnet_strength,
        legacy,
        add_original_image,
        cfg_rescale,
        noise_schedule,
        legacy_v3_extend,
        skip_cfg_above_sigma,
        use_coords,
        legacy_uc,
        normalize_reference_strength_multiple,
        v4_prompt,
        v4_negative_prompt,
        seed,
        const DeepCollectionEquality().hash(_characterPrompts),
        const DeepCollectionEquality().hash(_reference_image_multiple),
        const DeepCollectionEquality().hash(_reference_strength_multiple),
        negative_prompt,
        deliberate_euler_ancestral_bug,
        prefer_brownian,
        const DeepCollectionEquality().hash(_director_reference_descriptions),
        const DeepCollectionEquality().hash(_director_reference_images),
        const DeepCollectionEquality()
            .hash(_director_reference_information_extracted),
        const DeepCollectionEquality()
            .hash(_director_reference_secondary_strength_values),
        const DeepCollectionEquality().hash(_director_reference_strength_values)
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Parameters(params_version: $params_version, width: $width, height: $height, scale: $scale, sampler: $sampler, steps: $steps, n_samples: $n_samples, ucPreset: $ucPreset, qualityToggle: $qualityToggle, autoSmea: $autoSmea, dynamic_thresholding: $dynamic_thresholding, controlnet_strength: $controlnet_strength, legacy: $legacy, add_original_image: $add_original_image, cfg_rescale: $cfg_rescale, noise_schedule: $noise_schedule, legacy_v3_extend: $legacy_v3_extend, skip_cfg_above_sigma: $skip_cfg_above_sigma, use_coords: $use_coords, legacy_uc: $legacy_uc, normalize_reference_strength_multiple: $normalize_reference_strength_multiple, v4_prompt: $v4_prompt, v4_negative_prompt: $v4_negative_prompt, seed: $seed, characterPrompts: $characterPrompts, reference_image_multiple: $reference_image_multiple, reference_strength_multiple: $reference_strength_multiple, negative_prompt: $negative_prompt, deliberate_euler_ancestral_bug: $deliberate_euler_ancestral_bug, prefer_brownian: $prefer_brownian, director_reference_descriptions: $director_reference_descriptions, director_reference_images: $director_reference_images, director_reference_information_extracted: $director_reference_information_extracted, director_reference_secondary_strength_values: $director_reference_secondary_strength_values, director_reference_strength_values: $director_reference_strength_values)';
  }
}

/// @nodoc
abstract mixin class _$ParametersCopyWith<$Res>
    implements $ParametersCopyWith<$Res> {
  factory _$ParametersCopyWith(
          _Parameters value, $Res Function(_Parameters) _then) =
      __$ParametersCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int params_version,
      int width,
      int height,
      double scale,
      String sampler,
      int steps,
      int n_samples,
      int ucPreset,
      bool qualityToggle,
      bool autoSmea,
      bool dynamic_thresholding,
      int controlnet_strength,
      bool legacy,
      bool add_original_image,
      double cfg_rescale,
      String noise_schedule,
      bool legacy_v3_extend,
      int? skip_cfg_above_sigma,
      bool use_coords,
      bool legacy_uc,
      bool normalize_reference_strength_multiple,
      V4Prompt v4_prompt,
      V4NegativePrompt v4_negative_prompt,
      int seed,
      List<CharacterPrompt> characterPrompts,
      List<String> reference_image_multiple,
      List<double> reference_strength_multiple,
      String negative_prompt,
      bool deliberate_euler_ancestral_bug,
      bool prefer_brownian,
      List<DirectorReferenceDescription> director_reference_descriptions,
      List<String> director_reference_images,
      List<int> director_reference_information_extracted,
      List<double> director_reference_secondary_strength_values,
      List<double> director_reference_strength_values});

  @override
  $V4PromptCopyWith<$Res> get v4_prompt;
  @override
  $V4NegativePromptCopyWith<$Res> get v4_negative_prompt;
}

/// @nodoc
class __$ParametersCopyWithImpl<$Res> implements _$ParametersCopyWith<$Res> {
  __$ParametersCopyWithImpl(this._self, this._then);

  final _Parameters _self;
  final $Res Function(_Parameters) _then;

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? params_version = null,
    Object? width = null,
    Object? height = null,
    Object? scale = null,
    Object? sampler = null,
    Object? steps = null,
    Object? n_samples = null,
    Object? ucPreset = null,
    Object? qualityToggle = null,
    Object? autoSmea = null,
    Object? dynamic_thresholding = null,
    Object? controlnet_strength = null,
    Object? legacy = null,
    Object? add_original_image = null,
    Object? cfg_rescale = null,
    Object? noise_schedule = null,
    Object? legacy_v3_extend = null,
    Object? skip_cfg_above_sigma = freezed,
    Object? use_coords = null,
    Object? legacy_uc = null,
    Object? normalize_reference_strength_multiple = null,
    Object? v4_prompt = null,
    Object? v4_negative_prompt = null,
    Object? seed = null,
    Object? characterPrompts = null,
    Object? reference_image_multiple = null,
    Object? reference_strength_multiple = null,
    Object? negative_prompt = null,
    Object? deliberate_euler_ancestral_bug = null,
    Object? prefer_brownian = null,
    Object? director_reference_descriptions = null,
    Object? director_reference_images = null,
    Object? director_reference_information_extracted = null,
    Object? director_reference_secondary_strength_values = null,
    Object? director_reference_strength_values = null,
  }) {
    return _then(_Parameters(
      params_version: null == params_version
          ? _self.params_version
          : params_version // ignore: cast_nullable_to_non_nullable
              as int,
      width: null == width
          ? _self.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      scale: null == scale
          ? _self.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
      sampler: null == sampler
          ? _self.sampler
          : sampler // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _self.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      n_samples: null == n_samples
          ? _self.n_samples
          : n_samples // ignore: cast_nullable_to_non_nullable
              as int,
      ucPreset: null == ucPreset
          ? _self.ucPreset
          : ucPreset // ignore: cast_nullable_to_non_nullable
              as int,
      qualityToggle: null == qualityToggle
          ? _self.qualityToggle
          : qualityToggle // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSmea: null == autoSmea
          ? _self.autoSmea
          : autoSmea // ignore: cast_nullable_to_non_nullable
              as bool,
      dynamic_thresholding: null == dynamic_thresholding
          ? _self.dynamic_thresholding
          : dynamic_thresholding // ignore: cast_nullable_to_non_nullable
              as bool,
      controlnet_strength: null == controlnet_strength
          ? _self.controlnet_strength
          : controlnet_strength // ignore: cast_nullable_to_non_nullable
              as int,
      legacy: null == legacy
          ? _self.legacy
          : legacy // ignore: cast_nullable_to_non_nullable
              as bool,
      add_original_image: null == add_original_image
          ? _self.add_original_image
          : add_original_image // ignore: cast_nullable_to_non_nullable
              as bool,
      cfg_rescale: null == cfg_rescale
          ? _self.cfg_rescale
          : cfg_rescale // ignore: cast_nullable_to_non_nullable
              as double,
      noise_schedule: null == noise_schedule
          ? _self.noise_schedule
          : noise_schedule // ignore: cast_nullable_to_non_nullable
              as String,
      legacy_v3_extend: null == legacy_v3_extend
          ? _self.legacy_v3_extend
          : legacy_v3_extend // ignore: cast_nullable_to_non_nullable
              as bool,
      skip_cfg_above_sigma: freezed == skip_cfg_above_sigma
          ? _self.skip_cfg_above_sigma
          : skip_cfg_above_sigma // ignore: cast_nullable_to_non_nullable
              as int?,
      use_coords: null == use_coords
          ? _self.use_coords
          : use_coords // ignore: cast_nullable_to_non_nullable
              as bool,
      legacy_uc: null == legacy_uc
          ? _self.legacy_uc
          : legacy_uc // ignore: cast_nullable_to_non_nullable
              as bool,
      normalize_reference_strength_multiple: null ==
              normalize_reference_strength_multiple
          ? _self.normalize_reference_strength_multiple
          : normalize_reference_strength_multiple // ignore: cast_nullable_to_non_nullable
              as bool,
      v4_prompt: null == v4_prompt
          ? _self.v4_prompt
          : v4_prompt // ignore: cast_nullable_to_non_nullable
              as V4Prompt,
      v4_negative_prompt: null == v4_negative_prompt
          ? _self.v4_negative_prompt
          : v4_negative_prompt // ignore: cast_nullable_to_non_nullable
              as V4NegativePrompt,
      seed: null == seed
          ? _self.seed
          : seed // ignore: cast_nullable_to_non_nullable
              as int,
      characterPrompts: null == characterPrompts
          ? _self._characterPrompts
          : characterPrompts // ignore: cast_nullable_to_non_nullable
              as List<CharacterPrompt>,
      reference_image_multiple: null == reference_image_multiple
          ? _self._reference_image_multiple
          : reference_image_multiple // ignore: cast_nullable_to_non_nullable
              as List<String>,
      reference_strength_multiple: null == reference_strength_multiple
          ? _self._reference_strength_multiple
          : reference_strength_multiple // ignore: cast_nullable_to_non_nullable
              as List<double>,
      negative_prompt: null == negative_prompt
          ? _self.negative_prompt
          : negative_prompt // ignore: cast_nullable_to_non_nullable
              as String,
      deliberate_euler_ancestral_bug: null == deliberate_euler_ancestral_bug
          ? _self.deliberate_euler_ancestral_bug
          : deliberate_euler_ancestral_bug // ignore: cast_nullable_to_non_nullable
              as bool,
      prefer_brownian: null == prefer_brownian
          ? _self.prefer_brownian
          : prefer_brownian // ignore: cast_nullable_to_non_nullable
              as bool,
      director_reference_descriptions: null == director_reference_descriptions
          ? _self._director_reference_descriptions
          : director_reference_descriptions // ignore: cast_nullable_to_non_nullable
              as List<DirectorReferenceDescription>,
      director_reference_images: null == director_reference_images
          ? _self._director_reference_images
          : director_reference_images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      director_reference_information_extracted: null ==
              director_reference_information_extracted
          ? _self._director_reference_information_extracted
          : director_reference_information_extracted // ignore: cast_nullable_to_non_nullable
              as List<int>,
      director_reference_secondary_strength_values: null ==
              director_reference_secondary_strength_values
          ? _self._director_reference_secondary_strength_values
          : director_reference_secondary_strength_values // ignore: cast_nullable_to_non_nullable
              as List<double>,
      director_reference_strength_values: null ==
              director_reference_strength_values
          ? _self._director_reference_strength_values
          : director_reference_strength_values // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $V4PromptCopyWith<$Res> get v4_prompt {
    return $V4PromptCopyWith<$Res>(_self.v4_prompt, (value) {
      return _then(_self.copyWith(v4_prompt: value));
    });
  }

  /// Create a copy of Parameters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $V4NegativePromptCopyWith<$Res> get v4_negative_prompt {
    return $V4NegativePromptCopyWith<$Res>(_self.v4_negative_prompt, (value) {
      return _then(_self.copyWith(v4_negative_prompt: value));
    });
  }
}

/// @nodoc
mixin _$V4Prompt implements DiagnosticableTreeMixin {
  Caption get caption;
  bool get use_order;
  bool get use_coords;

  /// Create a copy of V4Prompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $V4PromptCopyWith<V4Prompt> get copyWith =>
      _$V4PromptCopyWithImpl<V4Prompt>(this as V4Prompt, _$identity);

  /// Serializes this V4Prompt to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'V4Prompt'))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('use_order', use_order))
      ..add(DiagnosticsProperty('use_coords', use_coords));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is V4Prompt &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.use_order, use_order) ||
                other.use_order == use_order) &&
            (identical(other.use_coords, use_coords) ||
                other.use_coords == use_coords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, caption, use_order, use_coords);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'V4Prompt(caption: $caption, use_order: $use_order, use_coords: $use_coords)';
  }
}

/// @nodoc
abstract mixin class $V4PromptCopyWith<$Res> {
  factory $V4PromptCopyWith(V4Prompt value, $Res Function(V4Prompt) _then) =
      _$V4PromptCopyWithImpl;
  @useResult
  $Res call({Caption caption, bool use_order, bool use_coords});

  $CaptionCopyWith<$Res> get caption;
}

/// @nodoc
class _$V4PromptCopyWithImpl<$Res> implements $V4PromptCopyWith<$Res> {
  _$V4PromptCopyWithImpl(this._self, this._then);

  final V4Prompt _self;
  final $Res Function(V4Prompt) _then;

  /// Create a copy of V4Prompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caption = null,
    Object? use_order = null,
    Object? use_coords = null,
  }) {
    return _then(_self.copyWith(
      caption: null == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as Caption,
      use_order: null == use_order
          ? _self.use_order
          : use_order // ignore: cast_nullable_to_non_nullable
              as bool,
      use_coords: null == use_coords
          ? _self.use_coords
          : use_coords // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of V4Prompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CaptionCopyWith<$Res> get caption {
    return $CaptionCopyWith<$Res>(_self.caption, (value) {
      return _then(_self.copyWith(caption: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _V4Prompt with DiagnosticableTreeMixin implements V4Prompt {
  const _V4Prompt(
      {required this.caption,
      required this.use_order,
      required this.use_coords});
  factory _V4Prompt.fromJson(Map<String, dynamic> json) =>
      _$V4PromptFromJson(json);

  @override
  final Caption caption;
  @override
  final bool use_order;
  @override
  final bool use_coords;

  /// Create a copy of V4Prompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$V4PromptCopyWith<_V4Prompt> get copyWith =>
      __$V4PromptCopyWithImpl<_V4Prompt>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$V4PromptToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'V4Prompt'))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('use_order', use_order))
      ..add(DiagnosticsProperty('use_coords', use_coords));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _V4Prompt &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.use_order, use_order) ||
                other.use_order == use_order) &&
            (identical(other.use_coords, use_coords) ||
                other.use_coords == use_coords));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, caption, use_order, use_coords);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'V4Prompt(caption: $caption, use_order: $use_order, use_coords: $use_coords)';
  }
}

/// @nodoc
abstract mixin class _$V4PromptCopyWith<$Res>
    implements $V4PromptCopyWith<$Res> {
  factory _$V4PromptCopyWith(_V4Prompt value, $Res Function(_V4Prompt) _then) =
      __$V4PromptCopyWithImpl;
  @override
  @useResult
  $Res call({Caption caption, bool use_order, bool use_coords});

  @override
  $CaptionCopyWith<$Res> get caption;
}

/// @nodoc
class __$V4PromptCopyWithImpl<$Res> implements _$V4PromptCopyWith<$Res> {
  __$V4PromptCopyWithImpl(this._self, this._then);

  final _V4Prompt _self;
  final $Res Function(_V4Prompt) _then;

  /// Create a copy of V4Prompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? caption = null,
    Object? use_order = null,
    Object? use_coords = null,
  }) {
    return _then(_V4Prompt(
      caption: null == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as Caption,
      use_order: null == use_order
          ? _self.use_order
          : use_order // ignore: cast_nullable_to_non_nullable
              as bool,
      use_coords: null == use_coords
          ? _self.use_coords
          : use_coords // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of V4Prompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CaptionCopyWith<$Res> get caption {
    return $CaptionCopyWith<$Res>(_self.caption, (value) {
      return _then(_self.copyWith(caption: value));
    });
  }
}

/// @nodoc
mixin _$V4NegativePrompt implements DiagnosticableTreeMixin {
  Caption get caption;
  bool get legacy_uc;

  /// Create a copy of V4NegativePrompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $V4NegativePromptCopyWith<V4NegativePrompt> get copyWith =>
      _$V4NegativePromptCopyWithImpl<V4NegativePrompt>(
          this as V4NegativePrompt, _$identity);

  /// Serializes this V4NegativePrompt to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'V4NegativePrompt'))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('legacy_uc', legacy_uc));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is V4NegativePrompt &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.legacy_uc, legacy_uc) ||
                other.legacy_uc == legacy_uc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, caption, legacy_uc);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'V4NegativePrompt(caption: $caption, legacy_uc: $legacy_uc)';
  }
}

/// @nodoc
abstract mixin class $V4NegativePromptCopyWith<$Res> {
  factory $V4NegativePromptCopyWith(
          V4NegativePrompt value, $Res Function(V4NegativePrompt) _then) =
      _$V4NegativePromptCopyWithImpl;
  @useResult
  $Res call({Caption caption, bool legacy_uc});

  $CaptionCopyWith<$Res> get caption;
}

/// @nodoc
class _$V4NegativePromptCopyWithImpl<$Res>
    implements $V4NegativePromptCopyWith<$Res> {
  _$V4NegativePromptCopyWithImpl(this._self, this._then);

  final V4NegativePrompt _self;
  final $Res Function(V4NegativePrompt) _then;

  /// Create a copy of V4NegativePrompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caption = null,
    Object? legacy_uc = null,
  }) {
    return _then(_self.copyWith(
      caption: null == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as Caption,
      legacy_uc: null == legacy_uc
          ? _self.legacy_uc
          : legacy_uc // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of V4NegativePrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CaptionCopyWith<$Res> get caption {
    return $CaptionCopyWith<$Res>(_self.caption, (value) {
      return _then(_self.copyWith(caption: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _V4NegativePrompt
    with DiagnosticableTreeMixin
    implements V4NegativePrompt {
  const _V4NegativePrompt({required this.caption, required this.legacy_uc});
  factory _V4NegativePrompt.fromJson(Map<String, dynamic> json) =>
      _$V4NegativePromptFromJson(json);

  @override
  final Caption caption;
  @override
  final bool legacy_uc;

  /// Create a copy of V4NegativePrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$V4NegativePromptCopyWith<_V4NegativePrompt> get copyWith =>
      __$V4NegativePromptCopyWithImpl<_V4NegativePrompt>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$V4NegativePromptToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'V4NegativePrompt'))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('legacy_uc', legacy_uc));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _V4NegativePrompt &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.legacy_uc, legacy_uc) ||
                other.legacy_uc == legacy_uc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, caption, legacy_uc);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'V4NegativePrompt(caption: $caption, legacy_uc: $legacy_uc)';
  }
}

/// @nodoc
abstract mixin class _$V4NegativePromptCopyWith<$Res>
    implements $V4NegativePromptCopyWith<$Res> {
  factory _$V4NegativePromptCopyWith(
          _V4NegativePrompt value, $Res Function(_V4NegativePrompt) _then) =
      __$V4NegativePromptCopyWithImpl;
  @override
  @useResult
  $Res call({Caption caption, bool legacy_uc});

  @override
  $CaptionCopyWith<$Res> get caption;
}

/// @nodoc
class __$V4NegativePromptCopyWithImpl<$Res>
    implements _$V4NegativePromptCopyWith<$Res> {
  __$V4NegativePromptCopyWithImpl(this._self, this._then);

  final _V4NegativePrompt _self;
  final $Res Function(_V4NegativePrompt) _then;

  /// Create a copy of V4NegativePrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? caption = null,
    Object? legacy_uc = null,
  }) {
    return _then(_V4NegativePrompt(
      caption: null == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as Caption,
      legacy_uc: null == legacy_uc
          ? _self.legacy_uc
          : legacy_uc // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of V4NegativePrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CaptionCopyWith<$Res> get caption {
    return $CaptionCopyWith<$Res>(_self.caption, (value) {
      return _then(_self.copyWith(caption: value));
    });
  }
}

/// @nodoc
mixin _$Caption implements DiagnosticableTreeMixin {
  String get base_caption;
  List<CharCaption> get char_captions;

  /// Create a copy of Caption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CaptionCopyWith<Caption> get copyWith =>
      _$CaptionCopyWithImpl<Caption>(this as Caption, _$identity);

  /// Serializes this Caption to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Caption'))
      ..add(DiagnosticsProperty('base_caption', base_caption))
      ..add(DiagnosticsProperty('char_captions', char_captions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Caption &&
            (identical(other.base_caption, base_caption) ||
                other.base_caption == base_caption) &&
            const DeepCollectionEquality()
                .equals(other.char_captions, char_captions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, base_caption,
      const DeepCollectionEquality().hash(char_captions));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Caption(base_caption: $base_caption, char_captions: $char_captions)';
  }
}

/// @nodoc
abstract mixin class $CaptionCopyWith<$Res> {
  factory $CaptionCopyWith(Caption value, $Res Function(Caption) _then) =
      _$CaptionCopyWithImpl;
  @useResult
  $Res call({String base_caption, List<CharCaption> char_captions});
}

/// @nodoc
class _$CaptionCopyWithImpl<$Res> implements $CaptionCopyWith<$Res> {
  _$CaptionCopyWithImpl(this._self, this._then);

  final Caption _self;
  final $Res Function(Caption) _then;

  /// Create a copy of Caption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base_caption = null,
    Object? char_captions = null,
  }) {
    return _then(_self.copyWith(
      base_caption: null == base_caption
          ? _self.base_caption
          : base_caption // ignore: cast_nullable_to_non_nullable
              as String,
      char_captions: null == char_captions
          ? _self.char_captions
          : char_captions // ignore: cast_nullable_to_non_nullable
              as List<CharCaption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Caption with DiagnosticableTreeMixin implements Caption {
  const _Caption(
      {required this.base_caption,
      final List<CharCaption> char_captions = const []})
      : _char_captions = char_captions;
  factory _Caption.fromJson(Map<String, dynamic> json) =>
      _$CaptionFromJson(json);

  @override
  final String base_caption;
  final List<CharCaption> _char_captions;
  @override
  @JsonKey()
  List<CharCaption> get char_captions {
    if (_char_captions is EqualUnmodifiableListView) return _char_captions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_char_captions);
  }

  /// Create a copy of Caption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CaptionCopyWith<_Caption> get copyWith =>
      __$CaptionCopyWithImpl<_Caption>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CaptionToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Caption'))
      ..add(DiagnosticsProperty('base_caption', base_caption))
      ..add(DiagnosticsProperty('char_captions', char_captions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Caption &&
            (identical(other.base_caption, base_caption) ||
                other.base_caption == base_caption) &&
            const DeepCollectionEquality()
                .equals(other._char_captions, _char_captions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, base_caption,
      const DeepCollectionEquality().hash(_char_captions));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Caption(base_caption: $base_caption, char_captions: $char_captions)';
  }
}

/// @nodoc
abstract mixin class _$CaptionCopyWith<$Res> implements $CaptionCopyWith<$Res> {
  factory _$CaptionCopyWith(_Caption value, $Res Function(_Caption) _then) =
      __$CaptionCopyWithImpl;
  @override
  @useResult
  $Res call({String base_caption, List<CharCaption> char_captions});
}

/// @nodoc
class __$CaptionCopyWithImpl<$Res> implements _$CaptionCopyWith<$Res> {
  __$CaptionCopyWithImpl(this._self, this._then);

  final _Caption _self;
  final $Res Function(_Caption) _then;

  /// Create a copy of Caption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? base_caption = null,
    Object? char_captions = null,
  }) {
    return _then(_Caption(
      base_caption: null == base_caption
          ? _self.base_caption
          : base_caption // ignore: cast_nullable_to_non_nullable
              as String,
      char_captions: null == char_captions
          ? _self._char_captions
          : char_captions // ignore: cast_nullable_to_non_nullable
              as List<CharCaption>,
    ));
  }
}

/// @nodoc
mixin _$CharCaption implements DiagnosticableTreeMixin {
  String get char_caption;
  List<Center> get centers;

  /// Create a copy of CharCaption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CharCaptionCopyWith<CharCaption> get copyWith =>
      _$CharCaptionCopyWithImpl<CharCaption>(this as CharCaption, _$identity);

  /// Serializes this CharCaption to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CharCaption'))
      ..add(DiagnosticsProperty('char_caption', char_caption))
      ..add(DiagnosticsProperty('centers', centers));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CharCaption &&
            (identical(other.char_caption, char_caption) ||
                other.char_caption == char_caption) &&
            const DeepCollectionEquality().equals(other.centers, centers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, char_caption, const DeepCollectionEquality().hash(centers));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CharCaption(char_caption: $char_caption, centers: $centers)';
  }
}

/// @nodoc
abstract mixin class $CharCaptionCopyWith<$Res> {
  factory $CharCaptionCopyWith(
          CharCaption value, $Res Function(CharCaption) _then) =
      _$CharCaptionCopyWithImpl;
  @useResult
  $Res call({String char_caption, List<Center> centers});
}

/// @nodoc
class _$CharCaptionCopyWithImpl<$Res> implements $CharCaptionCopyWith<$Res> {
  _$CharCaptionCopyWithImpl(this._self, this._then);

  final CharCaption _self;
  final $Res Function(CharCaption) _then;

  /// Create a copy of CharCaption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? char_caption = null,
    Object? centers = null,
  }) {
    return _then(_self.copyWith(
      char_caption: null == char_caption
          ? _self.char_caption
          : char_caption // ignore: cast_nullable_to_non_nullable
              as String,
      centers: null == centers
          ? _self.centers
          : centers // ignore: cast_nullable_to_non_nullable
              as List<Center>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _CharCaption with DiagnosticableTreeMixin implements CharCaption {
  const _CharCaption(
      {required this.char_caption, required final List<Center> centers})
      : _centers = centers;
  factory _CharCaption.fromJson(Map<String, dynamic> json) =>
      _$CharCaptionFromJson(json);

  @override
  final String char_caption;
  final List<Center> _centers;
  @override
  List<Center> get centers {
    if (_centers is EqualUnmodifiableListView) return _centers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_centers);
  }

  /// Create a copy of CharCaption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CharCaptionCopyWith<_CharCaption> get copyWith =>
      __$CharCaptionCopyWithImpl<_CharCaption>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CharCaptionToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CharCaption'))
      ..add(DiagnosticsProperty('char_caption', char_caption))
      ..add(DiagnosticsProperty('centers', centers));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CharCaption &&
            (identical(other.char_caption, char_caption) ||
                other.char_caption == char_caption) &&
            const DeepCollectionEquality().equals(other._centers, _centers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, char_caption, const DeepCollectionEquality().hash(_centers));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CharCaption(char_caption: $char_caption, centers: $centers)';
  }
}

/// @nodoc
abstract mixin class _$CharCaptionCopyWith<$Res>
    implements $CharCaptionCopyWith<$Res> {
  factory _$CharCaptionCopyWith(
          _CharCaption value, $Res Function(_CharCaption) _then) =
      __$CharCaptionCopyWithImpl;
  @override
  @useResult
  $Res call({String char_caption, List<Center> centers});
}

/// @nodoc
class __$CharCaptionCopyWithImpl<$Res> implements _$CharCaptionCopyWith<$Res> {
  __$CharCaptionCopyWithImpl(this._self, this._then);

  final _CharCaption _self;
  final $Res Function(_CharCaption) _then;

  /// Create a copy of CharCaption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? char_caption = null,
    Object? centers = null,
  }) {
    return _then(_CharCaption(
      char_caption: null == char_caption
          ? _self.char_caption
          : char_caption // ignore: cast_nullable_to_non_nullable
              as String,
      centers: null == centers
          ? _self._centers
          : centers // ignore: cast_nullable_to_non_nullable
              as List<Center>,
    ));
  }
}

/// @nodoc
mixin _$Center implements DiagnosticableTreeMixin {
  double get x;
  double get y;

  /// Create a copy of Center
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CenterCopyWith<Center> get copyWith =>
      _$CenterCopyWithImpl<Center>(this as Center, _$identity);

  /// Serializes this Center to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Center'))
      ..add(DiagnosticsProperty('x', x))
      ..add(DiagnosticsProperty('y', y));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Center &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Center(x: $x, y: $y)';
  }
}

/// @nodoc
abstract mixin class $CenterCopyWith<$Res> {
  factory $CenterCopyWith(Center value, $Res Function(Center) _then) =
      _$CenterCopyWithImpl;
  @useResult
  $Res call({double x, double y});
}

/// @nodoc
class _$CenterCopyWithImpl<$Res> implements $CenterCopyWith<$Res> {
  _$CenterCopyWithImpl(this._self, this._then);

  final Center _self;
  final $Res Function(Center) _then;

  /// Create a copy of Center
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_self.copyWith(
      x: null == x
          ? _self.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _self.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Center with DiagnosticableTreeMixin implements Center {
  const _Center({required this.x, required this.y});
  factory _Center.fromJson(Map<String, dynamic> json) => _$CenterFromJson(json);

  @override
  final double x;
  @override
  final double y;

  /// Create a copy of Center
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CenterCopyWith<_Center> get copyWith =>
      __$CenterCopyWithImpl<_Center>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CenterToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'Center'))
      ..add(DiagnosticsProperty('x', x))
      ..add(DiagnosticsProperty('y', y));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Center &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Center(x: $x, y: $y)';
  }
}

/// @nodoc
abstract mixin class _$CenterCopyWith<$Res> implements $CenterCopyWith<$Res> {
  factory _$CenterCopyWith(_Center value, $Res Function(_Center) _then) =
      __$CenterCopyWithImpl;
  @override
  @useResult
  $Res call({double x, double y});
}

/// @nodoc
class __$CenterCopyWithImpl<$Res> implements _$CenterCopyWith<$Res> {
  __$CenterCopyWithImpl(this._self, this._then);

  final _Center _self;
  final $Res Function(_Center) _then;

  /// Create a copy of Center
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? x = null,
    Object? y = null,
  }) {
    return _then(_Center(
      x: null == x
          ? _self.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: null == y
          ? _self.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$CharacterPrompt implements DiagnosticableTreeMixin {
  String get prompt;
  String get uc;
  Center get center;
  bool get enabled;

  /// Create a copy of CharacterPrompt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CharacterPromptCopyWith<CharacterPrompt> get copyWith =>
      _$CharacterPromptCopyWithImpl<CharacterPrompt>(
          this as CharacterPrompt, _$identity);

  /// Serializes this CharacterPrompt to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CharacterPrompt'))
      ..add(DiagnosticsProperty('prompt', prompt))
      ..add(DiagnosticsProperty('uc', uc))
      ..add(DiagnosticsProperty('center', center))
      ..add(DiagnosticsProperty('enabled', enabled));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CharacterPrompt &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.uc, uc) || other.uc == uc) &&
            (identical(other.center, center) || other.center == center) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, prompt, uc, center, enabled);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CharacterPrompt(prompt: $prompt, uc: $uc, center: $center, enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class $CharacterPromptCopyWith<$Res> {
  factory $CharacterPromptCopyWith(
          CharacterPrompt value, $Res Function(CharacterPrompt) _then) =
      _$CharacterPromptCopyWithImpl;
  @useResult
  $Res call({String prompt, String uc, Center center, bool enabled});

  $CenterCopyWith<$Res> get center;
}

/// @nodoc
class _$CharacterPromptCopyWithImpl<$Res>
    implements $CharacterPromptCopyWith<$Res> {
  _$CharacterPromptCopyWithImpl(this._self, this._then);

  final CharacterPrompt _self;
  final $Res Function(CharacterPrompt) _then;

  /// Create a copy of CharacterPrompt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? uc = null,
    Object? center = null,
    Object? enabled = null,
  }) {
    return _then(_self.copyWith(
      prompt: null == prompt
          ? _self.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      uc: null == uc
          ? _self.uc
          : uc // ignore: cast_nullable_to_non_nullable
              as String,
      center: null == center
          ? _self.center
          : center // ignore: cast_nullable_to_non_nullable
              as Center,
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of CharacterPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CenterCopyWith<$Res> get center {
    return $CenterCopyWith<$Res>(_self.center, (value) {
      return _then(_self.copyWith(center: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _CharacterPrompt with DiagnosticableTreeMixin implements CharacterPrompt {
  const _CharacterPrompt(
      {required this.prompt,
      required this.uc,
      required this.center,
      required this.enabled});
  factory _CharacterPrompt.fromJson(Map<String, dynamic> json) =>
      _$CharacterPromptFromJson(json);

  @override
  final String prompt;
  @override
  final String uc;
  @override
  final Center center;
  @override
  final bool enabled;

  /// Create a copy of CharacterPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CharacterPromptCopyWith<_CharacterPrompt> get copyWith =>
      __$CharacterPromptCopyWithImpl<_CharacterPrompt>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CharacterPromptToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CharacterPrompt'))
      ..add(DiagnosticsProperty('prompt', prompt))
      ..add(DiagnosticsProperty('uc', uc))
      ..add(DiagnosticsProperty('center', center))
      ..add(DiagnosticsProperty('enabled', enabled));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CharacterPrompt &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.uc, uc) || other.uc == uc) &&
            (identical(other.center, center) || other.center == center) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, prompt, uc, center, enabled);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CharacterPrompt(prompt: $prompt, uc: $uc, center: $center, enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class _$CharacterPromptCopyWith<$Res>
    implements $CharacterPromptCopyWith<$Res> {
  factory _$CharacterPromptCopyWith(
          _CharacterPrompt value, $Res Function(_CharacterPrompt) _then) =
      __$CharacterPromptCopyWithImpl;
  @override
  @useResult
  $Res call({String prompt, String uc, Center center, bool enabled});

  @override
  $CenterCopyWith<$Res> get center;
}

/// @nodoc
class __$CharacterPromptCopyWithImpl<$Res>
    implements _$CharacterPromptCopyWith<$Res> {
  __$CharacterPromptCopyWithImpl(this._self, this._then);

  final _CharacterPrompt _self;
  final $Res Function(_CharacterPrompt) _then;

  /// Create a copy of CharacterPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? prompt = null,
    Object? uc = null,
    Object? center = null,
    Object? enabled = null,
  }) {
    return _then(_CharacterPrompt(
      prompt: null == prompt
          ? _self.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      uc: null == uc
          ? _self.uc
          : uc // ignore: cast_nullable_to_non_nullable
              as String,
      center: null == center
          ? _self.center
          : center // ignore: cast_nullable_to_non_nullable
              as Center,
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of CharacterPrompt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CenterCopyWith<$Res> get center {
    return $CenterCopyWith<$Res>(_self.center, (value) {
      return _then(_self.copyWith(center: value));
    });
  }
}

/// @nodoc
mixin _$DirectorReferenceDescription implements DiagnosticableTreeMixin {
  DirectorCaption get caption;
  bool get legacy_uc;

  /// Create a copy of DirectorReferenceDescription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DirectorReferenceDescriptionCopyWith<DirectorReferenceDescription>
      get copyWith => _$DirectorReferenceDescriptionCopyWithImpl<
              DirectorReferenceDescription>(
          this as DirectorReferenceDescription, _$identity);

  /// Serializes this DirectorReferenceDescription to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DirectorReferenceDescription'))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('legacy_uc', legacy_uc));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DirectorReferenceDescription &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.legacy_uc, legacy_uc) ||
                other.legacy_uc == legacy_uc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, caption, legacy_uc);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DirectorReferenceDescription(caption: $caption, legacy_uc: $legacy_uc)';
  }
}

/// @nodoc
abstract mixin class $DirectorReferenceDescriptionCopyWith<$Res> {
  factory $DirectorReferenceDescriptionCopyWith(
          DirectorReferenceDescription value,
          $Res Function(DirectorReferenceDescription) _then) =
      _$DirectorReferenceDescriptionCopyWithImpl;
  @useResult
  $Res call({DirectorCaption caption, bool legacy_uc});

  $DirectorCaptionCopyWith<$Res> get caption;
}

/// @nodoc
class _$DirectorReferenceDescriptionCopyWithImpl<$Res>
    implements $DirectorReferenceDescriptionCopyWith<$Res> {
  _$DirectorReferenceDescriptionCopyWithImpl(this._self, this._then);

  final DirectorReferenceDescription _self;
  final $Res Function(DirectorReferenceDescription) _then;

  /// Create a copy of DirectorReferenceDescription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? caption = null,
    Object? legacy_uc = null,
  }) {
    return _then(_self.copyWith(
      caption: null == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as DirectorCaption,
      legacy_uc: null == legacy_uc
          ? _self.legacy_uc
          : legacy_uc // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of DirectorReferenceDescription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DirectorCaptionCopyWith<$Res> get caption {
    return $DirectorCaptionCopyWith<$Res>(_self.caption, (value) {
      return _then(_self.copyWith(caption: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _DirectorReferenceDescription
    with DiagnosticableTreeMixin
    implements DirectorReferenceDescription {
  const _DirectorReferenceDescription(
      {required this.caption, required this.legacy_uc});
  factory _DirectorReferenceDescription.fromJson(Map<String, dynamic> json) =>
      _$DirectorReferenceDescriptionFromJson(json);

  @override
  final DirectorCaption caption;
  @override
  final bool legacy_uc;

  /// Create a copy of DirectorReferenceDescription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DirectorReferenceDescriptionCopyWith<_DirectorReferenceDescription>
      get copyWith => __$DirectorReferenceDescriptionCopyWithImpl<
          _DirectorReferenceDescription>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DirectorReferenceDescriptionToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DirectorReferenceDescription'))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('legacy_uc', legacy_uc));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DirectorReferenceDescription &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.legacy_uc, legacy_uc) ||
                other.legacy_uc == legacy_uc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, caption, legacy_uc);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DirectorReferenceDescription(caption: $caption, legacy_uc: $legacy_uc)';
  }
}

/// @nodoc
abstract mixin class _$DirectorReferenceDescriptionCopyWith<$Res>
    implements $DirectorReferenceDescriptionCopyWith<$Res> {
  factory _$DirectorReferenceDescriptionCopyWith(
          _DirectorReferenceDescription value,
          $Res Function(_DirectorReferenceDescription) _then) =
      __$DirectorReferenceDescriptionCopyWithImpl;
  @override
  @useResult
  $Res call({DirectorCaption caption, bool legacy_uc});

  @override
  $DirectorCaptionCopyWith<$Res> get caption;
}

/// @nodoc
class __$DirectorReferenceDescriptionCopyWithImpl<$Res>
    implements _$DirectorReferenceDescriptionCopyWith<$Res> {
  __$DirectorReferenceDescriptionCopyWithImpl(this._self, this._then);

  final _DirectorReferenceDescription _self;
  final $Res Function(_DirectorReferenceDescription) _then;

  /// Create a copy of DirectorReferenceDescription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? caption = null,
    Object? legacy_uc = null,
  }) {
    return _then(_DirectorReferenceDescription(
      caption: null == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as DirectorCaption,
      legacy_uc: null == legacy_uc
          ? _self.legacy_uc
          : legacy_uc // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of DirectorReferenceDescription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DirectorCaptionCopyWith<$Res> get caption {
    return $DirectorCaptionCopyWith<$Res>(_self.caption, (value) {
      return _then(_self.copyWith(caption: value));
    });
  }
}

/// @nodoc
mixin _$DirectorCaption implements DiagnosticableTreeMixin {
  String get base_caption;
  List<CharCaption> get char_captions;

  /// Create a copy of DirectorCaption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DirectorCaptionCopyWith<DirectorCaption> get copyWith =>
      _$DirectorCaptionCopyWithImpl<DirectorCaption>(
          this as DirectorCaption, _$identity);

  /// Serializes this DirectorCaption to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DirectorCaption'))
      ..add(DiagnosticsProperty('base_caption', base_caption))
      ..add(DiagnosticsProperty('char_captions', char_captions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DirectorCaption &&
            (identical(other.base_caption, base_caption) ||
                other.base_caption == base_caption) &&
            const DeepCollectionEquality()
                .equals(other.char_captions, char_captions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, base_caption,
      const DeepCollectionEquality().hash(char_captions));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DirectorCaption(base_caption: $base_caption, char_captions: $char_captions)';
  }
}

/// @nodoc
abstract mixin class $DirectorCaptionCopyWith<$Res> {
  factory $DirectorCaptionCopyWith(
          DirectorCaption value, $Res Function(DirectorCaption) _then) =
      _$DirectorCaptionCopyWithImpl;
  @useResult
  $Res call({String base_caption, List<CharCaption> char_captions});
}

/// @nodoc
class _$DirectorCaptionCopyWithImpl<$Res>
    implements $DirectorCaptionCopyWith<$Res> {
  _$DirectorCaptionCopyWithImpl(this._self, this._then);

  final DirectorCaption _self;
  final $Res Function(DirectorCaption) _then;

  /// Create a copy of DirectorCaption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? base_caption = null,
    Object? char_captions = null,
  }) {
    return _then(_self.copyWith(
      base_caption: null == base_caption
          ? _self.base_caption
          : base_caption // ignore: cast_nullable_to_non_nullable
              as String,
      char_captions: null == char_captions
          ? _self.char_captions
          : char_captions // ignore: cast_nullable_to_non_nullable
              as List<CharCaption>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _DirectorCaption with DiagnosticableTreeMixin implements DirectorCaption {
  const _DirectorCaption(
      {required this.base_caption,
      final List<CharCaption> char_captions = const []})
      : _char_captions = char_captions;
  factory _DirectorCaption.fromJson(Map<String, dynamic> json) =>
      _$DirectorCaptionFromJson(json);

  @override
  final String base_caption;
  final List<CharCaption> _char_captions;
  @override
  @JsonKey()
  List<CharCaption> get char_captions {
    if (_char_captions is EqualUnmodifiableListView) return _char_captions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_char_captions);
  }

  /// Create a copy of DirectorCaption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DirectorCaptionCopyWith<_DirectorCaption> get copyWith =>
      __$DirectorCaptionCopyWithImpl<_DirectorCaption>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DirectorCaptionToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DirectorCaption'))
      ..add(DiagnosticsProperty('base_caption', base_caption))
      ..add(DiagnosticsProperty('char_captions', char_captions));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DirectorCaption &&
            (identical(other.base_caption, base_caption) ||
                other.base_caption == base_caption) &&
            const DeepCollectionEquality()
                .equals(other._char_captions, _char_captions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, base_caption,
      const DeepCollectionEquality().hash(_char_captions));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DirectorCaption(base_caption: $base_caption, char_captions: $char_captions)';
  }
}

/// @nodoc
abstract mixin class _$DirectorCaptionCopyWith<$Res>
    implements $DirectorCaptionCopyWith<$Res> {
  factory _$DirectorCaptionCopyWith(
          _DirectorCaption value, $Res Function(_DirectorCaption) _then) =
      __$DirectorCaptionCopyWithImpl;
  @override
  @useResult
  $Res call({String base_caption, List<CharCaption> char_captions});
}

/// @nodoc
class __$DirectorCaptionCopyWithImpl<$Res>
    implements _$DirectorCaptionCopyWith<$Res> {
  __$DirectorCaptionCopyWithImpl(this._self, this._then);

  final _DirectorCaption _self;
  final $Res Function(_DirectorCaption) _then;

  /// Create a copy of DirectorCaption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? base_caption = null,
    Object? char_captions = null,
  }) {
    return _then(_DirectorCaption(
      base_caption: null == base_caption
          ? _self.base_caption
          : base_caption // ignore: cast_nullable_to_non_nullable
              as String,
      char_captions: null == char_captions
          ? _self._char_captions
          : char_captions // ignore: cast_nullable_to_non_nullable
              as List<CharCaption>,
    ));
  }
}

// dart format on
