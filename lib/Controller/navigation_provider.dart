import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  RxBool _isCollapsed = false.obs;

  RxBool get isCollapsed => _isCollapsed;

  void toggleIsCollapsed() {
    _isCollapsed.value = !_isCollapsed.value;
    debugPrint(_isCollapsed.value.toString());
  }
}
