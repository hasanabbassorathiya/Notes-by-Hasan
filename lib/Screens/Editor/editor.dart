import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/updateNoteController.dart';
import 'package:notes/Services/Database.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuillController _controller = QuillController.basic();
  final _titleTextController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Color> colors1 = [];
  Color pickerColor = Colors.lightBlueAccent;
  Color currentColor = Colors.white;
  bool isSwitched = false;
  int indexOfCurrentColor;
  final _check = Icon(
    Icons.check,
    color: Colors.black,
    size: 20,
  );

  @override
  void initState() {
    //getTheme();
    if (Get.put<UpdateNoteController>(UpdateNoteController()).isUpdate.value ==
        true) {
      isNew();
    } else {}
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  SharedPreferences prefs;

  getTheme() async {
    var up =
        Get.put<UpdateNoteController>(UpdateNoteController()).upateNoteModel;
    prefs = await SharedPreferences.getInstance();
    isSwitched = prefs.getBool('isDarkTheme') ?? false;
    setState(() {});
  }

  bool isNewNote = false;
  sendNewNote() async {
    try {
      if ((_titleTextController.text.isNotEmpty) &&
          (!_controller.document.isEmpty())) {
        await Database().addNotes(
          _titleTextController.text,
          jsonEncode(_controller.document.toDelta().toJson()),
          pickerColor,
        );
        Get.back();
        print(_titleTextController.text);
        print(jsonEncode(_controller.document.toDelta().toJson()));
        Get.snackbar('Added Successfully', '',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: pickerColor);
      } else {
        Get.snackbar('Title / Description cannot be empty', '',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: pickerColor);
      }
    } on Exception catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: pickerColor);
    }
  }

  updateNote() async {
    var up =
        Get.put<UpdateNoteController>(UpdateNoteController()).upateNoteModel;
    setState(() {
      changeColor(getcolor(up.color));
    });
    try {
      if ((_titleTextController.text.isNotEmpty) &&
          (!_controller.document.isEmpty())) {
        await Database().updateNotes(
            id: up.id,
            content: jsonEncode(_controller.document.toDelta().toJson()),
            title: _titleTextController.text,
            color: pickerColor,
            date: up.date);

        print(_titleTextController.text);
        print(jsonEncode(_controller.document.toDelta().toJson()));
        Get.back();
        Get.snackbar(
          "",
          "",
          snackPosition: SnackPosition.BOTTOM,
          titleText: Text(
            'Updated Successfully',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          messageText: Text(
            '${_titleTextController.text}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: pickerColor,
        );
      } else {
        Get.snackbar("", "",
            titleText: Text(
              'Title / Description cannot be empty',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
              ),
            ),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green);
      }
    } on Exception catch (e) {
      Get.snackbar('Error', " ",
          messageText: Text(
            '${e.toString()}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green);
      Get.back();
    }
  }

  getcolor(color) {
    String colorString = color.toString(); // Color(0x12345678)
    String valueString =
        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    Color otherColor = new Color(value);
    debugPrint('UP COLOR' + otherColor.toString());
    changeColor(otherColor);
    return otherColor;
  }

  GenerateColor() {
    for (int i = 0; i < 4000; i++) {
      Color _randomColor =
          Colors.primaries[Random().nextInt(Colors.primaries.length)]
              [Random().nextInt(9) * 100];
      colors1.add(_randomColor);
    }
  }

  isNew() {
    var up =
        Get.put<UpdateNoteController>(UpdateNoteController()).upateNoteModel;
    changeColor(
      getcolor(up.color),
    );

    if (!up.isNull) {
      setState(() {
        _titleTextController.text = up.title;
        var myJSON = jsonDecode(up.content);

        _controller = QuillController(
          document: Document.fromJson(myJSON),
          selection: TextSelection.collapsed(offset: 0),
        );
      });
    }
  }

  GlobalKey previewContainer = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RepaintBoundary(
        key: previewContainer,
        child: Scaffold(
            extendBody: true,
            bottomSheet: QuillToolbar.basic(
              controller: _controller,
            ),
            appBar: AppBar(
              centerTitle: true,
              title: InkWell(
                onTap: () {
                  _contentFocusNode.unfocus();
                },
                child: Container(
                  padding: EdgeInsets.all(5),
//          decoration: BoxDecoration(border: Border.all(color: CentralStation.borderColor,width: 1 ),borderRadius: BorderRadius.all(Radius.circular(10)) ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your title here',
                      hintStyle: Theme.of(context).textTheme.headline5.copyWith(
                            fontSize: 20,
                            color: Colors.black54.withOpacity(0.4),
                          ),
                    ),
                    controller: _titleTextController,
                    focusNode: _titleFocusNode,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 20),
                    cursorColor: Colors.blue,
                  ),
                ),
              ),
              backgroundColor: pickerColor,
              actions: [
                IconButton(
                  icon: CircleAvatar(
                    backgroundColor: pickerColor == Colors.black
                        ? Colors.white.withOpacity(0.8)
                        : Colors.black.withOpacity(0.8),
                    radius: 11,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: pickerColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Select a color',
                          ),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: currentColor,
                              onColorChanged: changeColor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                    icon: Icon(
                      Icons.share_sharp,
                    ),
                    onPressed: () async {
                      ShareFilesAndScreenshotWidgets().shareScreenshot(
                        previewContainer,
                        MediaQuery.of(context).size.height.toInt(),
                        _titleTextController.text,
                        "Name.png",
                        "image/png",
                        text: (_controller.document.toPlainText()),
                      );
                    }),
                IconButton(
                    icon: Icon(
                      Icons.check,
                    ),
                    onPressed: () async {
                      Get.put<UpdateNoteController>(UpdateNoteController())
                              .isUpdate
                              .value
                          ? updateNote()
                          : sendNewNote();
                    }),
              ],
              elevation: 1.0,
            ),
            body: StatefulBuilder(builder: (context, snapshot) {
              return GestureDetector(
                onTap: () {
                  _titleFocusNode.unfocus();
                },
                child: Container(
                  color: pickerColor,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: QuillEditor(
                            controller: _controller,
                            scrollController: ScrollController(),
                            scrollable: true,

                            focusNode: _contentFocusNode,
                            autoFocus: false,
                            readOnly: false,
                            enableInteractiveSelection: true,
                            expands: false,
                            padding: EdgeInsets.zero,
                            placeholder: "Compose your notes...",
                            // change to true to be view only mode
                          ),
                        ),
                      ),
                      // FlatButton(
                      //   onPressed: () {
                      //     var json =
                      //         jsonEncode(_controller.document.toDelta().toJson());
                      //     var incomingJSONText = [
                      //       {
                      //         "insert": "Helllo",
                      //         "attributes": {
                      //           "bold": true,
                      //           "color": "#f4511e",
                      //           "background": "#ff8a80"
                      //         }
                      //       },
                      //       {"insert": "\n\n"}
                      //     ];
                      //     // var myJSON = jsonDecode(incomingJSONText);
                      //     _controller = QuillController(
                      //         document: Document.fromJson(incomingJSONText),
                      //         selection: TextSelection.collapsed(offset: 0));
                      //     debugPrint(json);
                      //     setState(() {});
                      //   },
                      //   child: Text('TAP'),
                      // )
                    ],
                  ),
                ),
              );
            })),
      ),
    );
  }
}
