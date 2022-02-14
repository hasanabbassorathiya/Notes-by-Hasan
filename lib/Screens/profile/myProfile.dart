import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/Controller/authController.dart';
import 'package:notes/Controller/userController.dart';
import 'package:notes/components/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final controller = Get.put(UserController());
  final controller1 = Get.put(AuthController());

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  File _image;

  final picker = ImagePicker();
  SharedPreferences prefs;

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

  getData() async {
    setState(() {
      nameController.text = controller.userModel.name.toString() ?? '';
      emailController.text = controller.userModel.email.toString() ?? '';
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          centerTitle: true,
          title: Text('My Profile'),
        ),
        drawer: NavigationDrawerWidget(),
        drawerEnableOpenDragGesture: true,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   alignment: Alignment.topLeft,
              //   padding: EdgeInsets.symmetric(horizontal: 40),
              //   child: CircleAvatar(
              //     backgroundColor: Colors.blue,
              //     child: IconButton(
              //       icon: Icon(
              //         Icons.menu,
              //         color: Colors.white,
              //       ),
              //       onPressed: () {
              //         _key.currentState.openDrawer();
              //       },
              //     ),
              //   ),
              // ),
              // SizedBox(height: size.height * 0.01),
              // Container(
              //   alignment: Alignment.centerLeft,
              //   padding: EdgeInsets.symmetric(horizontal: 40),
              //   child: Text(
              //     "MY PROFILE",
              //     style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         color: Color(0xFF2661FA),
              //         fontSize: 36),
              //     textAlign: TextAlign.left,
              //   ),
              // ),
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
                                      : controller.userModel.profilePic !=
                                                  null &&
                                              controller.userModel.profilePic
                                                  .isNotEmpty
                                          ? NetworkImage(controller
                                              .userModel.profilePic
                                              .toString())
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
                            readOnly: true,
                            decoration: InputDecoration(labelText: "Email"),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          child: TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                                labelText: "Change Password",
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.blue),
                                focusColor: Theme.of(context).primaryColor),
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
                              }
                              // else if (passwordController.text.isEmpty) {
                              //   Get.snackbar(
                              //       'Required', 'Please enter your password',
                              //       snackPosition: SnackPosition.BOTTOM,
                              //       backgroundColor: Colors.red,
                              //       colorText: Colors.white);
                              // }
                              else if (passwordController.text.isNotEmpty &&
                                  passwordController.text.length < 6) {
                                Get.snackbar('Error',
                                    'Please enter password more than 6 digits',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                              } else {
                                if (nameController.text.isNotEmpty &&
                                    emailController.text.isNotEmpty) {
                                  setState(() {
                                    controller.isLoad = true;
                                  });
                                  if (_image != null) {
                                    String url =
                                        await controller1.uploadImageToFirebase(
                                            profilePic: _image,
                                            userEmail: emailController.text
                                                .toString());

                                    debugPrint(url.toString());

                                    controller1.MyProfileUpdate(
                                            name: nameController.text,
                                            email: emailController.text,
                                            password: passwordController.text,
                                            url: url)
                                        .then(
                                      (value) => setState(
                                        () {
                                          debugPrint('$value');

                                          controller.isLoad = false;
                                        },
                                      ),
                                    );
                                    setState(() {
                                      controller.isLoad = false;
                                    });
                                  } else {
                                    controller1.MyProfileUpdate(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                    ).then((value) => setState(() {
                                          controller.isLoad = false;
                                        }));
                                    setState(() {
                                      controller.isLoad = false;
                                    });
                                  }
                                }
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
                                "Update",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
