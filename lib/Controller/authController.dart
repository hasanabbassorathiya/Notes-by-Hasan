import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/userController.dart';
import 'package:notes/Home.dart';
import 'package:notes/Services/Database.dart';
import 'package:notes/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<FirebaseUser> _firebaseuser = Rx<FirebaseUser>();
  SharedPreferences prefs;

  String get user => _firebaseuser.value?.email;

  String get userPic => _firebaseuser.value?.photoUrl;

  @override
  void onInit() {
    _firebaseuser.bindStream(_auth.onAuthStateChanged);
    super.onInit();
  }

  void signUp(String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      UserModel _user = UserModel(
        id: authResult.user.uid,
        name: name,
        email: email,
      );
      if (await Database().createNewUser(_user)) {
        Get.find<UserController>().userModel = _user;
        Get.to(Home());
      }
    } catch (e) {
      Get.snackbar('Error creating account', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    }
  }

  void login(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      Get.find<UserController>().userModel =
          await Database().getUser(authResult.user.uid);
      Get.to(Home());
    } catch (e) {
      Get.snackbar('Error While Logging', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    }
  }

  void signOut() async {
    try {
      await _auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      Get.find<UserController>().clear();
    } catch (e) {
      Get.snackbar('Error While Signing out', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    }
  }
}
