// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diffusion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiffusionModel _$DiffusionModelFromJson(Map<String, dynamic> json) =>
    _DiffusionModel(
      input: json['input'] as String,
      model: json['model'] as String,
      action: json['action'] as String,
      parameters:
          Parameters.fromJson(json['parameters'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DiffusionModelToJson(_DiffusionModel instance) =>
    <String, dynamic>{
      'input': instance.input,
      'model': instance.model,
      'action': instance.action,
      'parameters': instance.parameters,
    };

_Parameters _$ParametersFromJson(Map<String, dynamic> json) => _Parameters(
      params_version: (json['params_version'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      scale: (json['scale'] as num).toDouble(),
      sampler: json['sampler'] as String,
      steps: (json['steps'] as num).toInt(),
      n_samples: (json['n_samples'] as num).toInt(),
      ucPreset: (json['ucPreset'] as num).toInt(),
      qualityToggle: json['qualityToggle'] as bool,
      autoSmea: json['autoSmea'] as bool,
      dynamic_thresholding: json['dynamic_thresholding'] as bool,
      controlnet_strength: (json['controlnet_strength'] as num).toInt(),
      legacy: json['legacy'] as bool,
      add_original_image: json['add_original_image'] as bool,
      cfg_rescale: (json['cfg_rescale'] as num).toDouble(),
      noise_schedule: json['noise_schedule'] as String,
      legacy_v3_extend: json['legacy_v3_extend'] as bool,
      skip_cfg_above_sigma: (json['skip_cfg_above_sigma'] as num?)?.toInt(),
      use_coords: json['use_coords'] as bool,
      legacy_uc: json['legacy_uc'] as bool,
      normalize_reference_strength_multiple:
          json['normalize_reference_strength_multiple'] as bool,
      v4_prompt: V4Prompt.fromJson(json['v4_prompt'] as Map<String, dynamic>),
      v4_negative_prompt: V4NegativePrompt.fromJson(
          json['v4_negative_prompt'] as Map<String, dynamic>),
      seed: (json['seed'] as num).toInt(),
      characterPrompts: (json['characterPrompts'] as List<dynamic>)
          .map((e) => CharacterPrompt.fromJson(e as Map<String, dynamic>))
          .toList(),
      reference_image_multiple:
          (json['reference_image_multiple'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      reference_strength_multiple:
          (json['reference_strength_multiple'] as List<dynamic>?)
                  ?.map((e) => (e as num).toDouble())
                  .toList() ??
              const [],
      negative_prompt: json['negative_prompt'] as String,
      deliberate_euler_ancestral_bug:
          json['deliberate_euler_ancestral_bug'] as bool,
      prefer_brownian: json['prefer_brownian'] as bool,
    );

Map<String, dynamic> _$ParametersToJson(_Parameters instance) =>
    <String, dynamic>{
      'params_version': instance.params_version,
      'width': instance.width,
      'height': instance.height,
      'scale': instance.scale,
      'sampler': instance.sampler,
      'steps': instance.steps,
      'n_samples': instance.n_samples,
      'ucPreset': instance.ucPreset,
      'qualityToggle': instance.qualityToggle,
      'autoSmea': instance.autoSmea,
      'dynamic_thresholding': instance.dynamic_thresholding,
      'controlnet_strength': instance.controlnet_strength,
      'legacy': instance.legacy,
      'add_original_image': instance.add_original_image,
      'cfg_rescale': instance.cfg_rescale,
      'noise_schedule': instance.noise_schedule,
      'legacy_v3_extend': instance.legacy_v3_extend,
      'skip_cfg_above_sigma': instance.skip_cfg_above_sigma,
      'use_coords': instance.use_coords,
      'legacy_uc': instance.legacy_uc,
      'normalize_reference_strength_multiple':
          instance.normalize_reference_strength_multiple,
      'v4_prompt': instance.v4_prompt,
      'v4_negative_prompt': instance.v4_negative_prompt,
      'seed': instance.seed,
      'characterPrompts': instance.characterPrompts,
      'reference_image_multiple': instance.reference_image_multiple,
      'reference_strength_multiple': instance.reference_strength_multiple,
      'negative_prompt': instance.negative_prompt,
      'deliberate_euler_ancestral_bug': instance.deliberate_euler_ancestral_bug,
      'prefer_brownian': instance.prefer_brownian,
    };

_V4Prompt _$V4PromptFromJson(Map<String, dynamic> json) => _V4Prompt(
      caption: Caption.fromJson(json['caption'] as Map<String, dynamic>),
      use_order: json['use_order'] as bool,
      use_coords: json['use_coords'] as bool,
    );

Map<String, dynamic> _$V4PromptToJson(_V4Prompt instance) => <String, dynamic>{
      'caption': instance.caption,
      'use_order': instance.use_order,
      'use_coords': instance.use_coords,
    };

_V4NegativePrompt _$V4NegativePromptFromJson(Map<String, dynamic> json) =>
    _V4NegativePrompt(
      caption: Caption.fromJson(json['caption'] as Map<String, dynamic>),
      legacy_uc: json['legacy_uc'] as bool,
    );

Map<String, dynamic> _$V4NegativePromptToJson(_V4NegativePrompt instance) =>
    <String, dynamic>{
      'caption': instance.caption,
      'legacy_uc': instance.legacy_uc,
    };

_Caption _$CaptionFromJson(Map<String, dynamic> json) => _Caption(
      base_caption: json['base_caption'] as String,
      char_captions: (json['char_captions'] as List<dynamic>?)
              ?.map((e) => CharCaption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CaptionToJson(_Caption instance) => <String, dynamic>{
      'base_caption': instance.base_caption,
      'char_captions': instance.char_captions,
    };

_CharCaption _$CharCaptionFromJson(Map<String, dynamic> json) => _CharCaption(
      char_caption: json['char_caption'] as String,
      centers: (json['centers'] as List<dynamic>)
          .map((e) => Center.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CharCaptionToJson(_CharCaption instance) =>
    <String, dynamic>{
      'char_caption': instance.char_caption,
      'centers': instance.centers,
    };

_Center _$CenterFromJson(Map<String, dynamic> json) => _Center(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$CenterToJson(_Center instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
    };

_CharacterPrompt _$CharacterPromptFromJson(Map<String, dynamic> json) =>
    _CharacterPrompt(
      prompt: json['prompt'] as String,
      uc: json['uc'] as String,
      center: Center.fromJson(json['center'] as Map<String, dynamic>),
      enabled: json['enabled'] as bool,
    );

Map<String, dynamic> _$CharacterPromptToJson(_CharacterPrompt instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'uc': instance.uc,
      'center': instance.center,
      'enabled': instance.enabled,
    };
