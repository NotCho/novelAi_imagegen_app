// 필요한 패키지 import
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

// freezed가 생성할 파일들
part 'diffusion_model.freezed.dart';

part 'diffusion_model.g.dart';

@freezed
abstract class DiffusionModel with _$DiffusionModel {
  const factory DiffusionModel({
    required String input,
    required String model,
    required String action,
    required Parameters parameters,
  }) = _DiffusionModel;

  factory DiffusionModel.fromJson(Map<String, dynamic> json) =>
      _$DiffusionModelFromJson(json);
}

@freezed
abstract class Parameters with _$Parameters {
  const factory Parameters({
    required int params_version,
    required int width,
    required int height,
    required double scale,
    required String sampler,
    required int steps,
    required int n_samples,
    required int ucPreset,
    required bool qualityToggle,
    required bool autoSmea,
    required bool dynamic_thresholding,
    required int controlnet_strength,
    required bool legacy,
    required bool add_original_image,
    required double cfg_rescale,
    required String noise_schedule,
    required bool legacy_v3_extend,
    int? skip_cfg_above_sigma,
    required bool use_coords,
    required bool legacy_uc,
    required bool normalize_reference_strength_multiple,
    required V4Prompt v4_prompt,
    required V4NegativePrompt v4_negative_prompt,
    required int seed,
    required List<CharacterPrompt> characterPrompts,
    @Default([]) List<String> reference_image_multiple,
    @Default([]) List<double> reference_strength_multiple,
    required String negative_prompt,
    required bool deliberate_euler_ancestral_bug,
    required bool prefer_brownian,
  }) = _Parameters;

  factory Parameters.fromJson(Map<String, dynamic> json)
    // List<String> keys = [
    //   "params_version",
    //   "width",
    //   "height",
    //   "scale",
    //   "sampler",
    //   "steps",
    //   "n_samples",
    //   "ucPreset",
    //   "qualityToggle",
    //   "autoSmea",
    //   "dynamic_thresholding",
    //   "controlnet_strength",
    //   "legacy",
    //   "add_original_image",
    //   "cfg_rescale",
    //   "noise_schedule",
    //   "legacy_v3_extend",
    //   "skip_cfg_above_sigma",
    //   "use_coords",
    //   "legacy_uc",
    //   "normalize_reference_strength_multiple",
    //   "v4_prompt",
    //   "v4_negative_prompt",
    //   "seed",
    //   "characterPrompts",
    //   "reference_image_multiple",
    //   "reference_strength_multiple",
    //   "negative_prompt",
    //   "deliberate_euler_ancestral_bug",
    //   "prefer_brownian",
    // ];
    // for (String key in keys) {
    //   if (!json.containsKey(key)) {
    //     throw ArgumentError('Missing required key: $key');
    //   }
    // }
    => _$ParametersFromJson(json);

}

@freezed
abstract class V4Prompt with _$V4Prompt {
  const factory V4Prompt({
    required Caption caption,
    required bool use_order,
    required bool use_coords,
  }) = _V4Prompt;

  factory V4Prompt.fromJson(Map<String, dynamic> json) =>
      _$V4PromptFromJson(json);
}

@freezed
abstract class V4NegativePrompt with _$V4NegativePrompt {
  const factory V4NegativePrompt({
    required Caption caption,
    required bool legacy_uc,
  }) = _V4NegativePrompt;

  factory V4NegativePrompt.fromJson(Map<String, dynamic> json) =>
      _$V4NegativePromptFromJson(json);
}

@freezed
abstract class Caption with _$Caption {
  const factory Caption({
    required String base_caption,
    @Default([]) List<CharCaption> char_captions,
  }) = _Caption;

  factory Caption.fromJson(Map<String, dynamic> json) =>
      _$CaptionFromJson(json);
}

@freezed
abstract class CharCaption with _$CharCaption {
  const factory CharCaption({
    required String char_caption,
    required List<Center> centers,
  }) = _CharCaption;

  factory CharCaption.fromJson(Map<String, dynamic> json) =>
      _$CharCaptionFromJson(json);
}

@freezed
abstract class Center with _$Center {
  const factory Center({
    required double x,
    required double y,
  }) = _Center;

  factory Center.fromJson(Map<String, dynamic> json) => _$CenterFromJson(json);
}

@freezed
abstract class CharacterPrompt with _$CharacterPrompt {
  const factory CharacterPrompt({
    required String prompt,
    required String uc,
    required Center center,
    required bool enabled,
  }) = _CharacterPrompt;

  factory CharacterPrompt.fromJson(Map<String, dynamic> json) =>
      _$CharacterPromptFromJson(json);
}
