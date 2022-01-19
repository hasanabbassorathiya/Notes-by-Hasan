import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/authController.dart';
import 'package:notes/Controller/userController.dart';
import 'package:notes/Home.dart';
import 'package:notes/Screens/login/login.dart';

class Root extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return GetX(initState: (_) async {
      Get.put<UserController>(UserController());
    }, builder: (_) {
      if (Get.find<AuthController>().user != null) {
        return Home();
      } else {
        return LoginScreen();
      }
    });
  }
}
