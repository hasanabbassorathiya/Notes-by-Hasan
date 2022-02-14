import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/components/navigation_drawer_widget.dart';

class FeedbackForm extends StatefulWidget {
  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  List<String> attachments = [];
  bool isHTML = false;

  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  TextEditingController firstname = TextEditingController();
  TextEditingController email = TextEditingController();

  TextEditingController Bodymessage = TextEditingController();

  final _firstnameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _BodymessageFocusNode = FocusNode();
  @override
  void dispose() {
    firstname.dispose();
    email.dispose();
    Bodymessage.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Feedback form'),
      ),
      drawer: NavigationDrawerWidget(),
      body: InkWell(
        onTap: () {
          _firstnameFocusNode.unfocus();
          _emailFocusNode.unfocus();
          _BodymessageFocusNode.unfocus();
        },
        child: isLoading == false
            ? Container(
                height: double.maxFinite,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage("images/bg.jpeg"),
                //     colorFilter: ColorFilter.mode(
                //         Colors.black.withOpacity(0.9), BlendMode.dstATop),
                //     fit: BoxFit.cover,
                //   ),
                // ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Builder(
                            builder: (context) => Form(
                                  key: _formKey,
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            focusNode: _firstnameFocusNode,
                                            keyboardType: TextInputType.name,
                                            controller: firstname,
                                            decoration: InputDecoration(
                                              labelText: 'Full name',
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              focusColor: Colors.white,
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              focusedBorder:
                                                  new OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              fillColor: Colors.black54,
                                              filled: true,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            onEditingComplete: () {
                                              _firstnameFocusNode
                                                  .requestFocus();
                                            },
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter your full name.';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          TextFormField(
                                            focusNode: _emailFocusNode,
                                            controller: email,
                                            onEditingComplete: () {
                                              _emailFocusNode.requestFocus();
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'E-mail',
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              focusColor: Colors.white,
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              focusedBorder:
                                                  new OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              fillColor: Colors.black54,
                                              filled: true,
                                              border:
                                                  const OutlineInputBorder(),
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter your E-mail.';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          TextFormField(
                                            onEditingComplete: () {
                                              _BodymessageFocusNode.unfocus();
                                            },
                                            focusNode: _BodymessageFocusNode,
                                            textInputAction:
                                                TextInputAction.newline,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: Bodymessage,
                                            maxLines: 300,
                                            minLines: 20,
                                            decoration: InputDecoration(
                                              labelText: 'Message',
                                              focusColor: Colors.white,
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                // width: 0.0 produces a thin "hairline" border
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              focusedBorder:
                                                  new OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.white,
                                                    width: 0.0),
                                              ),
                                              fillColor: Colors.black54,
                                              filled: true,
                                              border:
                                                  const OutlineInputBorder(),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              alignLabelWithHint: true,
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please enter your feedback.';
                                              } else {
                                                return null;
                                              }
                                            },
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                        RaisedButton(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.02),
                          ),
                          color: Colors.red,
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            if (_formKey.currentState.validate()) {
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content:
                                      Text('Please check the missing fields')));
                            }
                            setState(() {
                              isLoading = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
      ),
    );
  }

  Future _openImagePicker() async {
    File pick = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (pick != null) {
      setState(() {
        attachments.add(pick.path);
      });
    }
    return pick.path.split('/').last;
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  void Clear() {
    firstname.clear();
    Bodymessage.clear();
  }
}
