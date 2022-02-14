import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/Controller/authController.dart';
import 'package:notes/Screens/login/login.dart';
import 'package:notes/components/background.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  File _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  final controller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Background(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "REGISTER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2661FA),
                        fontSize: 36),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                controller.isLoad
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              await getImage();
                            },
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: Get.width * 0.2 + 0.1,
                                  backgroundColor: Colors.black,
                                  child: CircleAvatar(
                                    radius: Get.width * 0.2,
                                    backgroundColor: Colors.blue.shade200,
                                    backgroundImage: _image != null
                                        ? FileImage(_image)
                                        : AssetImage(
                                            'assets/images/blankpp.png',
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 1,
                                  right: 10,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(labelText: "Name"),
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(labelText: "Email"),
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              controller: passwordController,
                              decoration:
                                  InputDecoration(labelText: "Password"),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: size.height * 0.05),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            child: RaisedButton(
                              onPressed: () async {
                                if (nameController.text.isEmpty) {
                                  Get.snackbar(
                                      'Required', 'Please enter your name',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                } else if (emailController.text.isEmpty) {
                                  Get.snackbar(
                                      'Required', 'Please enter your email',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                } else if (passwordController.text.isEmpty) {
                                  Get.snackbar(
                                      'Required', 'Please enter your password',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                } else if (passwordController.text.length < 6) {
                                  Get.snackbar('Error',
                                      'Please enter password more than 6 digits',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                }
                                if (nameController.text.isNotEmpty &&
                                    emailController.text.isNotEmpty &&
                                    (passwordController.text.isNotEmpty &&
                                        passwordController.text.length >= 6)) {
                                  setState(() {
                                    controller.isLoad = true;
                                  });
                                  String url = (_image != null)
                                      ? await controller.uploadImageToFirebase(
                                          profilePic: _image,
                                          userEmail:
                                              emailController.text.toString())
                                      : '';

                                  debugPrint(url.toString());

                                  controller
                                      .signUp(
                                          name: nameController.text,
                                          email: emailController.text,
                                          password: passwordController.text,
                                          url: url)
                                      .then((value) => setState(() {
                                            controller.isLoad = false;
                                          }));
                                  setState(() {
                                    controller.isLoad = false;
                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0)),
                              textColor: Colors.white,
                              padding: const EdgeInsets.all(0),
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                width: size.width * 0.5,
                                decoration: new BoxDecoration(
                                    borderRadius: BorderRadius.circular(80.0),
                                    gradient: new LinearGradient(colors: [
                                      Color.fromARGB(255, 255, 136, 34),
                                      Color.fromARGB(255, 255, 177, 41)
                                    ])),
                                padding: const EdgeInsets.all(0),
                                child: Text(
                                  "SIGN UP",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            child: GestureDetector(
                              onTap: () => {Get.to(LoginScreen())},
                              child: Text(
                                "Already Have an Account? Sign in",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2661FA)),
                              ),
                            ),
                          ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
