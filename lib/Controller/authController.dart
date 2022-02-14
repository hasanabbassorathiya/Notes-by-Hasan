import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/Root.dart';
import 'package:notes/Controller/userController.dart';
import 'package:notes/Home.dart';
import 'package:notes/Services/Database.dart';
import 'package:notes/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<FirebaseUser> _firebaseuser = Rx<FirebaseUser>();
  SharedPreferences prefs;
  bool isLoad = false;
  AuthResult userResult;
  AuthResult authResult;
  String get user => _firebaseuser.value?.email;

  String get userPic => _firebaseuser.value?.photoUrl;

  @override
  void onInit() {
    _firebaseuser.bindStream(_auth.onAuthStateChanged);
    super.onInit();
  }

  Future<void> signUp(
      {String name, String email, String password, String url}) async {
    try {
      authResult = await _auth
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password)
          .then((value) => userResult = value);
      UserModel _user = UserModel(
          id: authResult.user.uid,
          name: name,
          email: email,
          profilePic: url ?? '');
      if (await Database().createNewUser(_user)) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        Get.find<UserController>().userModel = _user;
        print(_user.name.toString());
        prefs.setString('name', _user.name.toString());
        prefs.setString('id', _user.id.toString());
        prefs.setString('email', _user.email.toString());
        prefs.setString('profilePic', _user.profilePic.toString());

        Get.to(Root());
      }
    } on PlatformException catch (err) {
      print(err.code.toString());
      Get.snackbar('Error creating account', err.message.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future MyProfileUpdate(
      {String name, String email, String password, String url}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // if (email != null && email.isNotEmpty) {
      //   userResult.user.updateEmail(email);
      // }
      if (password != null && password.isNotEmpty) {
        debugPrint('issue 7A here');
        try {
          userResult.user.updatePassword(password);
          Get.find<UserController>().userModel =
              await Database().getUser(prefs.get('id'));
          Get.to(Root());
          return Get.snackbar("Profile updated Successfully", '',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        } on PlatformException catch (err) {
          debugPrint('issue 7 here');
          debugPrint('issue ${err.message} ');

          return Get.snackbar("Error", '${err.message.toString()}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else if (url != null && url.isNotEmpty) {
        debugPrint('issue 11 here');
      } else {
        debugPrint('issue 8 here');

        UserModel _user = url != null && url.isNotEmpty
            ? UserModel(
                id: prefs.get('id'),
                name: name ?? prefs.get('name'),
                email: email,
                profilePic: url)
            : UserModel(
                id: prefs.get('id'),
                name: name ?? prefs.get('name'),
                email: email,
                profilePic: prefs.get('profilePic'));
        if (await Database().updateUser(_user)) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          Get.find<UserController>().userModel = _user;

          Get.find<UserController>().userModel = _user;
          Get.find<UserController>().userModel =
              await Database().getUser(_user.id);
          Get.to(Root());
          return 'success';
        } else {
          debugPrint('issue 6 here');
          return 'failed';
        }
      }
    } on PlatformException catch (err) {
      print(err.code.toString());
      Get.snackbar('Error while saving', err.message.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return 'error';
    }
  }

  void login(String email, String password) async {
    try {
      authResult = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .then((value) => userResult = value);
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
      Get.to(Root());
    } catch (e) {
      Get.snackbar('Error While Signing out', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    }
  }

  Future<String> uploadphotofile({image, userEmail}) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference ref =
        storage.ref().child('Pictures/' + userEmail.toString());
    await ref.putFile(File(image.path));
    String imageUrl = await ref.getDownloadURL();
    print(imageUrl.toString());
    return imageUrl;
  }

  Future uploadImageToFirebase({File profilePic, String userEmail}) async {
    String fileName = profilePic.path;
    String imageUrl;
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(
          'ProfilePic/${userEmail.toString()}/$fileName',
        );
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(
      profilePic,
    );
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then(
      (value) {
        print("Done: $value");
        imageUrl = value;
      },
    );
    return imageUrl;
  }

  Future<bool> validatePassword(String password) async {
    var firebaseUser = await _auth.currentUser();

    var authCredentials = EmailAuthProvider.getCredential(
        email: firebaseUser.email, password: password);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updatePassword(String password) async {
    var firebaseUser = await _auth.currentUser();
    firebaseUser.updatePassword(password);
  }
}
