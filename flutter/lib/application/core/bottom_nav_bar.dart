import 'package:get/get.dart';
import 'package:naiapp/application/core/skeleton_controller.dart';

class BottomNavBarController extends SkeletonController {
  final _currentIndex = 0.obs;
  final type = ''.obs;
  int get currentIndex => _currentIndex.value;

  set currentIndex(int newIndex) {
    if (_currentIndex.value == newIndex) {
      return;
    }
    _currentIndex.value = newIndex;
    if (newIndex == 0) {
    } else {
      throw 'wrong index';
    }
  }

  set justChangeIndex(int newIndex) {
    if (_currentIndex.value == newIndex) {
      return;
    }
    _currentIndex.value = newIndex;
  }

  @override
  Future<bool> initLoading() async {
    return true;
  }
}
