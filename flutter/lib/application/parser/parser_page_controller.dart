import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';

import 'package:get/get.dart';
import 'package:naiapp/application/home/home_page_controller.dart';
import 'package:naiapp/domain/gen/i_novelAI_repository.dart';
import 'package:naiapp/domain/gen/tag_suggestion_model.dart';

class ParserPageController extends SkeletonController {
  String prompt;
  final RxList<TagData> parsedData = RxList<TagData>();

  final RxList<TagModel> suggestedTags = RxList<TagModel>();

  TextEditingController searchController = TextEditingController();
  TextEditingController addTagController = TextEditingController();
  TextEditingController currentTagController = TextEditingController();

  final RxString searchQuery = ''.obs;

  ParserPageController({
    required this.prompt,
  });

  @override
  Future<bool> initLoading() async {
    encodePrompt();
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
    });
    return true;
  }

  void updateTagText(int index) {
    List<TagData> newParsedData = List.from(parsedData);

    newParsedData[index].text = currentTagController.text.trim();

    parsedData.value = newParsedData;
  }

  void suggestTag() async {
    if (addTagController.text.isEmpty) {
      return;
    }
    suggestedTags.clear();
    INovelAIRepository repository = Get.find<INovelAIRepository>();
    Either<String, TagSuggestionModel> data = await repository.suggestTags(
        addTagController.text, Get.find<HomePageController>().usingModel.value);
    data.fold((l) {
      Get.snackbar('Error', l, snackPosition: SnackPosition.BOTTOM);
    }, (r) {
      print('r.tags: ${r.tags}');
      if (r.tags.isNotEmpty) {
        for (TagModel tag in r.tags) {
          suggestedTags.add(tag);
        }
      } else {
        Get.snackbar('No Suggestions', 'No tags found for your input.',
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  void encodePrompt() {
    parsedData.value = prompt
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => _parseTag(tag))
        .toList();
  }

  void onSliderChanged(int index, double value) {
    if (index < 0 || index >= parsedData.length) return;

    // 가중치 업데이트 (RxList는 자동으로 UI 갱신)
    parsedData[index].weight = value;
    parsedData.refresh(); // RxList 강제 갱신
  }

  void addWeightByButton(int index, double increment) {
    if (index < 0 || index >= parsedData.length) return;

    // 가중치 증가
    parsedData[index].weight += increment;
    parsedData.refresh(); // RxList 강제 갱신
  }

  bool isTagHighlighted(TagData tag) {
    if (searchQuery.value.isEmpty) return false;
    return tag.text.toLowerCase().contains(searchQuery.value);
  }

  TagData _parseTag(String tag) {
    // {} 패턴 체크 (중첩된 중괄호 - 곱하기)
    if (tag.contains('{') && tag.contains('}')) {
      return _parseBraceTag(tag);
    }

    // [] 패턴 체크 (중첩된 대괄호 - 나누기)
    if (tag.contains('[') && tag.contains(']')) {
      return _parseBracketTag(tag);
    }

    // ::숫자:: 패턴 체크
    if (tag.contains('::') && RegExp(r'^-?\d+(\.\d+)?::').hasMatch(tag)) {
      return _parseWeightTag(tag);
    }

    // 일반 태그
    return TagData(tag, 1.0);
  }

  TagData _parseBracketTag(String tag) {
    int openBrackets = 0;
    int startIndex = 0;
    int endIndex = tag.length - 1;

    // 앞쪽 대괄호 개수 세기
    for (int i = 0; i < tag.length; i++) {
      if (tag[i] == '[') {
        openBrackets++;
        startIndex = i + 1;
      } else {
        break;
      }
    }

    // 뒤쪽 대괄호 확인하며 텍스트 추출
    for (int i = tag.length - 1; i >= 0; i--) {
      if (tag[i] == ']') {
        endIndex = i;
      } else {
        break;
      }
    }

    String text = tag.substring(startIndex, endIndex);
    double weight = 1.0;

    // 1.05로 openBrackets번 나누기 (= 1/1.05의 openBrackets제곱)
    for (int i = 0; i < openBrackets; i++) {
      weight /= 1.05;
    }

    return TagData(text, weight);
  }

  TagData _parseBraceTag(String tag) {
    int openBraces = 0;
    int startIndex = 0;
    int endIndex = tag.length - 1;

    // 앞쪽 중괄호 개수 세기
    for (int i = 0; i < tag.length; i++) {
      if (tag[i] == '{') {
        openBraces++;
        startIndex = i + 1;
      } else {
        break;
      }
    }

    // 뒤쪽 중괄호 확인하며 텍스트 추출
    for (int i = tag.length - 1; i >= 0; i--) {
      if (tag[i] == '}') {
        endIndex = i;
      } else {
        break;
      }
    }

    String text = tag.substring(startIndex, endIndex);
    double weight = 1.0;

    // 1.05의 openBraces제곱 계산
    for (int i = 0; i < openBraces; i++) {
      weight *= 1.05;
    }

    return TagData(text, weight);
  }

  TagData _parseWeightTag(String tag) {
    // 음수 포함해서 가중치 잡아내기
    final match = RegExp(r'^(-?\d+(?:\.\d+)?)::(.*)::$').firstMatch(tag);

    if (match != null) {
      double weight = double.parse(match.group(1)!);
      String text = match.group(2)!.trim();
      return TagData(text, weight);
    }

    return TagData(tag, 1.0);
  }

  void decodePrompt() {
    prompt = parsedData.map((tagData) {
      if (tagData.weight == 1.0) {
        return tagData.text;
      } else {
        String weightStr = tagData.weight.toStringAsFixed(2);
        // 텍스트 끝에 공백 추가하여 숫자 혼동 방지
        return '${double.parse(weightStr)}::${tagData.text} ::';
      }
    }).join(', ');
    prompt = '$prompt,'; // 마지막에 공백 추가하여 텍스트 끝 공백 처리
  }

  Color get promptOriginalColor => Colors.black45;

  Color getWeightColor(double weight) {
    if (weight == 1.0) {
      // 1.0일 때 무채색 (회색)
      return Colors.grey[600]!;
    } else if (weight > 1.0) {
      // 1.0~10.0 범위에서 파란색으로 변화
      // 10.0 이상일 때 최대 진한 파란색
      double intensity = ((weight - 1.0) / (10.0 - 1.0)).clamp(0.0, 1.0);
      return Color.lerp(Colors.grey[600]!, Colors.blue[700]!, intensity)!;
    } else {
      double intensity = ((1.0 - weight) / (1.0 - -10.0)).clamp(0.0, 1.0);
      return Color.lerp(Colors.grey[600]!, Colors.red[700]!, intensity)!;
    }
  }

  void reorderTags(int oldIndex, int newIndex) {
    final item = parsedData.removeAt(oldIndex);
    parsedData.insert(newIndex, item);
  }

  void finishParsing() {
    decodePrompt();
    Get.back(result: prompt);
  }

  void deleteTag(TagData tagData) {
    parsedData.remove(tagData);
  }

  void addTag() {
    String tagText = addTagController.text.trim();
    if (tagText.isEmpty) return;

    // 중복된 태그는 추가하지 않음
    if (parsedData.any((tag) => tag.text == tagText)) return;

    // 기본 가중치 1.0으로 새 태그 추가
    parsedData.add(TagData(tagText, 1.0));
  }
}

class TagData {
  String text;
  double weight;

  TagData(this.text, this.weight);

  @override
  String toString() => 'TagData(text: $text, weight: $weight)';
}
