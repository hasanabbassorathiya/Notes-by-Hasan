import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:notes/Controller/updateNoteController.dart';
import 'package:notes/Services/Database.dart';
import 'package:notes/models/NotesModel.dart';

import 'Home.dart';

class NoteEditor extends StatefulWidget {
  @override
  _NoteEditorState createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _titleTextController = TextEditingController();
  final _contentTextController = TextEditingController();
  Color pickerColor = Colors.lightBlueAccent;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  bool isUpdate = false;

  // ZefyrController _titlecontroller;
  // ZefyrController _contentcontroller;

  final _titleFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();
  Color currentColor = Colors.white;
  Note note;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Color> colors1 = [];
  @override
  void initState() {
    GenerateColor();
    if (Get.put<UpdateNoteController>(UpdateNoteController()).isUpdate.value ==
        true) {
      isNew();
    } else {
      // Delta titleDelta = Delta()..insert('Title \n');
      // Delta contentDelta = Delta()..insert('Notes \n');
      // _titlecontroller = ZefyrController(NotusDocument.fromDelta(titleDelta));
      // _contentcontroller =
      //     ZefyrController(NotusDocument.fromDelta(contentDelta));
    }

    super.initState();
  }

  getcolor(color) {
    String colorString = color.toString(); // Color(0x12345678)
    String valueString =
        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    Color otherColor = new Color(value);
    return otherColor;
  }

  isNew() {
    var up =
        Get.put<UpdateNoteController>(UpdateNoteController()).upateNoteModel;

    print(up.title);
    if (!up.isNull) {
      setState(() {
        changeColor(getcolor(up.color));
        _titleTextController.text = up.title;
        // Delta titleDelta = Delta()..insert(up.title + '\n' + up.content + '\n');
        // Delta contentDelta = Delta()..insert(up.content + '\n');
        // _titlecontroller = ZefyrController(NotusDocument.fromDelta(titleDelta));
        // _contentcontroller =
        //     ZefyrController(NotusDocument.fromDelta(contentDelta));
        _contentTextController.text = up.content;

        print(_contentTextController.text);
      });
    }
  }

  GenerateColor() {
    for (int i = 0; i < 4000; i++) {
      Color _randomColor =
          Colors.primaries[Random().nextInt(Colors.primaries.length)]
              [Random().nextInt(9) * 100];
      colors1.add(_randomColor);
    }
  }

  sendNewNote() async {
    try {
      if ((_titleTextController.text.isNotEmpty) ||
          (_contentTextController.text.isNotEmpty)) {
        await Database().addNotes(_titleTextController.text,
            _contentTextController.text, pickerColor);
        Get.back();
        print(_titleTextController.text);
        print(_contentTextController.text);
        Get.snackbar('Added Successfully', '',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue);
      } else {
        Get.snackbar('Title / Description cannot be empty', '',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue);
      }
    } on Exception catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue);
    }
  }

  updateNote() async {
    var up =
        Get.put<UpdateNoteController>(UpdateNoteController()).upateNoteModel;

    try {
      if ((_titleTextController.text.isNotEmpty) ||
          (_contentTextController.text.isNotEmpty)) {
        await Database().updateNotes(
            id: up.id,
            content: _contentTextController.text,
            title: _titleTextController.text,
            color: pickerColor,
            date: up.date);

        print(_titleTextController.text);
        print(_contentTextController.text);
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
            backgroundColor: pickerColor);
      }
    } on Exception catch (e) {
      Get.snackbar('Error', " ",
          messageText: Text(
            '${e.toString()}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: pickerColor);
      Get.back();
    }
  }

  DateFormat dateFormat;
  DateFormat timeFormat;

  final _check = Icon(
    Icons.check,
    color: Colors.black,
    size: 20,
  );
  int indexOfCurrentColor;

  Widget _checkOrNot(int index) {
    indexOfCurrentColor =
        colors1.indexWhere((element) => element == pickerColor);

    if (indexOfCurrentColor == index) {
      return _check;
    }
    return null;
  }

  final Color borderColor = Color(0xffd3d3d3);
  final Color foregroundColor = Color(0xff595959);

  Widget Modo() {
    return Container(
      color: pickerColor,
      child: new Wrap(
        children: <Widget>[
          new ListTile(
              leading: new Icon(
                  (Get.put<UpdateNoteController>(UpdateNoteController())
                              .isUpdate
                              .value ==
                          true)
                      ? Icons.delete
                      : Icons.cancel_outlined),
              title: new Text(
                  (Get.put<UpdateNoteController>(UpdateNoteController())
                              .isUpdate
                              .value ==
                          true)
                      ? 'Delete permanently'
                      : 'Discard'),
              onTap: () {
                if (Get.put<UpdateNoteController>(UpdateNoteController())
                        .isUpdate
                        .value ==
                    true) {
                  var up = Get.put<UpdateNoteController>(UpdateNoteController())
                      .upateNoteModel;

                  Database().deleteNotes(up.id);
                  Get.to(Home());
                } else {
                  Get.to(Home());
                }
              }),
          new ListTile(
              leading: new Icon(Icons.content_copy),
              title: new Text('Duplicate'),
              onTap: () {
                Navigator.of(context).pop();
              }),
          new ListTile(
              leading: new Icon(Icons.share),
              title: new Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
              }),
          new Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              height: 44,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(colors1.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      changeColor(colors1[index]);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 6, right: 6),
                      child: Container(
                        child: new CircleAvatar(
                          child: _checkOrNot(index),
                          foregroundColor: foregroundColor,
                          backgroundColor: colors1[index],
                        ),
                        width: 38.0,
                        height: 38.0,
                        padding: const EdgeInsets.all(1.0),
                        // border width
                        decoration: BoxDecoration(
                          color: borderColor, // border color
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                child: Center(
                  child: Text('Made By Hasan Abbas Sorathiya'),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          new ListTile()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: pickerColor,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext ctx) {
                          return Modo();
                        });
                  });
                  setState(() {});
                },
                child: Icon(
                  Icons.more_vert,
                ),
              ),
            ),
          ),
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
          // IconButton(
          //   icon: CircleAvatar(
          //     backgroundColor: pickerColor == Colors.black
          //         ? Colors.white.withOpacity(0.8)
          //         : Colors.black.withOpacity(0.8),
          //     radius: 14,
          //     child: CircleAvatar(
          //       radius: 10,
          //       backgroundColor: pickerColor,
          //       foregroundColor: Colors.white,
          //     ),
          //   ),
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text(
          //             'Select a color',
          //           ),
          //           content: SingleChildScrollView(
          //             child: BlockPicker(
          //               pickerColor: currentColor,
          //               onColorChanged: changeColor,
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
      backgroundColor: pickerColor,
      body: _body(context),
    );
  }

  Widget _body(BuildContext ctx) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
//          decoration: BoxDecoration(border: Border.all(color: CentralStation.borderColor,width: 1 ),borderRadius: BorderRadius.all(Radius.circular(10)) ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Title',
                      hintStyle: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(fontSize: 26),
                    ),
                    controller: _titleTextController,
                    focusNode: _titleFocusNode,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        .copyWith(fontSize: 26),
                    cursorColor: Colors.blue,
                  ),
                ),
                // Divider(
                //   color: Theme.of(context).dividerColor,
                // ),
                Container(
                    padding: EdgeInsets.all(5),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Description',
                        hintStyle: Theme.of(context).textTheme.headline6,
                      ),
                      maxLines: null,
                      // line limit extendable later
                      controller: _contentTextController,
                      focusNode: _contentFocusNode,
                      style: Theme.of(context).textTheme.headline6,

                      cursorColor: Colors.blue,
                    ))
              ],
            ),
            left: true,
            right: true,
            top: false,
            bottom: true,
          )),
    );
  }
}

// ZefyrScaffold(
//         child: ZefyrEditor(
//             controller: _titlecontroller, focusNode: _titleFocusNode),
//       ),

// SingleChildScrollView(
// padding: const EdgeInsets.all(20),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.stretch,
// children: <Widget>[
// Container(
// child: TextField(
// focusNode: _titleFocusNode,
// keyboardType: TextInputType.multiline,
// textInputAction: TextInputAction.newline,
// controller: _titleTextController,
// autocorrect: true,
// style: Theme.of(context)
// .textTheme
//     .headline4
//     .copyWith(color: Colors.black),
// decoration: const InputDecoration(
// hintText: 'Title',
// hintStyle: TextStyle(color: Colors.white),
// border: InputBorder.none,
// counter: const SizedBox(),
// ),
// textCapitalization: TextCapitalization.sentences,
// ),
// ),
// Container(
// child: TextField(
// focusNode: _contentFocusNode,
// keyboardType: TextInputType.multiline,
// textInputAction: TextInputAction.newline,
// showCursor: true,
// controller: _contentTextController,
// style: Theme.of(context)
// .textTheme
//     .headline5
//     .copyWith(color: Colors.black87),
// decoration: const InputDecoration.collapsed(
// hintText: 'Description',
// hintStyle: TextStyle(color: Colors.white),
// ),
// textCapitalization: TextCapitalization.sentences,
// autocorrect: true,
// onSubmitted: (_) {
// Get.close(1);
// },
// ),
// ),
// ],
// ),
// )
