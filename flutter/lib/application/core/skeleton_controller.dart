import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:naiapp/application/core/router.dart';

import 'global_controller.dart';

abstract class SkeletonController extends GetxController {
  final global = Get.find<GlobalController>();
  final code = ''.obs;
  final _isInitLoading = true.obs;

  set isLoading(bool value) => global.isLoading = value;

  bool get isLoading => global.isLoading;

  bool get isInitLoading => _isInitLoading.value;

  ISkeletonRouter get router => global.router;

  Future<bool> initLoading();

  @override
  Future<void> onInit() async {
    super.onInit();
    final initialLoadResult = await initLoading();
    if (kDebugMode) {
      print('initialLoadResult: $initialLoadResult');
    }
    _isInitLoading.value = false;
    if (!initialLoadResult) {
      await global.pageInitLoadingFail();
    }
  }
}
