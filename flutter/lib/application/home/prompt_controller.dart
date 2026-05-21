import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/gen/diffusion_model.dart' as df;

class PromptController extends GetxController {
  final positivePromptController = TextEditingController();
  final negativePromptController = TextEditingController();

  RxList<Map<String, dynamic>> characterPrompts = <Map<String, dynamic>>[].obs;
  RxInt selectedCharacterIndex = 0.obs;
  RxBool confirmRemoveIndex = false.obs;
  
  Rx<df.Center> characterPositions = const df.Center(x: 0.5, y: 0.5).obs;
  final characterScrollController = ScrollController();

  double convertPosition(double value) {
    return value * 10;
  }

  void setCharacterPosition(int x, int y) {
    // 소수점 첫째자리 까지만 저장
    double parsedX = double.parse((((x * 2) + 1) * 0.1).toStringAsFixed(1));
    double parsedY = double.parse((((y * 2) + 1) * 0.1).toStringAsFixed(1));

    characterPositions.value = df.Center(
      x: parsedX,
      y: parsedY,
    );

    if (selectedCharacterIndex.value >= 0 &&
        selectedCharacterIndex.value < characterPrompts.length) {
      characterPrompts[selectedCharacterIndex.value]['prompt'] =
          characterPrompts[selectedCharacterIndex.value]['prompt']
              .copyWith(center: characterPositions.value);
      update();
    }
  }

  bool isCharacterEnabled(int index) {
    if (index < 0 || index >= characterPrompts.length) return false;
    return characterPrompts[index]['prompt'].enabled == true;
  }

  void toggleSelectedCharacterEnabled() {
    final index = selectedCharacterIndex.value;
    if (index < 0 || index >= characterPrompts.length) return;

    final df.CharacterPrompt prompt = characterPrompts[index]['prompt'];
    characterPrompts[index]['prompt'] =
        prompt.copyWith(enabled: !prompt.enabled);
    characterPrompts.refresh();
  }

  void onCharaAddButtonTap() {
    characterPrompts.add({
      'prompt': const df.CharacterPrompt(
        prompt: '',
        uc: '',
        center: df.Center(x: 0.5, y: 0.5),
        enabled: true,
      ),
      'positive': TextEditingController(),
      'negative': TextEditingController(),
    });
    selectedCharacterIndex.value = characterPrompts.length - 1;
    characterScrollController.animateTo(
      characterScrollController.position.maxScrollExtent + 25,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  void onCharaRemoveButtonTap() {
    int index = selectedCharacterIndex.value;
    if (confirmRemoveIndex.value) {
      if (index - 1 < 0) {
        if (characterPrompts.length > 1) {
          selectedCharacterIndex.value = 0;
        } else {
          selectedCharacterIndex.value = index + 1;
        }
        selectedCharacterIndex.value = 0;
      } else {
        selectedCharacterIndex.value = index - 1;
      }
      
      // Dispose controllers in the removed item to avoid memory leaks
      try {
        final item = characterPrompts[index];
        (item['positive'] as TextEditingController).dispose();
        (item['negative'] as TextEditingController).dispose();
      } catch (e) {
        print('Error disposing character controllers: $e');
      }

      characterPrompts.removeAt(index);
      confirmRemoveIndex.value = false;
    } else {
      confirmRemoveIndex.value = true;
    }
  }

  void onCharaTap(int index) {
    if (index < 0 || index >= characterPrompts.length) return;
    selectedCharacterIndex.value = index;
    characterPositions.value = characterPrompts[index]['prompt'].center;
    characterScrollController.animateTo(
      0 + (index * 61),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    positivePromptController.dispose();
    negativePromptController.dispose();
    characterScrollController.dispose();
    
    // Dispose all text controllers within the characterPrompts list
    for (final item in characterPrompts) {
      try {
        (item['positive'] as TextEditingController).dispose();
        (item['negative'] as TextEditingController).dispose();
      } catch (e) {
        print('Error disposing character controllers in onClose: $e');
      }
    }
    super.onClose();
  }
}
