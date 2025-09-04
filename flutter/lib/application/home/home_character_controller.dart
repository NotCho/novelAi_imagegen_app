import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:naiapp/domain/gen/diffusion_model.dart' as df;

class HomeCharacterController extends GetxController {
  RxInt selectedCharacterIndex = 0.obs;
  RxBool confirmRemoveIndex = false.obs;
  RxList<Map<String, dynamic>> characterPrompts = <Map<String, dynamic>>[].obs;
  ScrollController characterScrollController = ScrollController();
  Rx<df.Center> characterPositions = df.Center(x: 0.5, y: 0.5).obs;

  @override
  void onClose() {
    for (var char in characterPrompts) {
      char['positive'].dispose();
      char['negative'].dispose();
    }
    characterScrollController.dispose();
    super.onClose();
  }

  void setCharacterPosition(int x, int y) {
    // 소수점 첫째자리 까지만 저장
    double parsedX = double.parse((((x * 2) + 1) * 0.1).toStringAsFixed(1));
    double parsedY = double.parse((((y * 2) + 1) * 0.1).toStringAsFixed(1));

    characterPositions.value = df.Center(
      x: parsedX,
      y: parsedY,
    );

    characterPrompts[selectedCharacterIndex.value]['prompt'] =
        characterPrompts[selectedCharacterIndex.value]['prompt']
            .copyWith(center: characterPositions.value);
    print('Character position set to: x=$parsedX, y=$parsedY');
    update();
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
}
