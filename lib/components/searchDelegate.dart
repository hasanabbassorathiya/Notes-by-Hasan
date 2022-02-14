import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/updateNoteController.dart';
import 'package:notes/Screens/Editor/editor.dart';
import 'package:notes/Services/Database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate() : super(searchFieldLabel: "Search notes");
  _ago(Timestamp t) {
    return timeago.format(t.toDate(), locale: 'en_long', allowFromNow: true);
  }

  bool isSwitched = false;
  String name = " ";
  String fullname = '';
  var id;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs = await SharedPreferences.getInstance();
    isSwitched = prefs.getBool('isDarkTheme') ?? false;

    id = prefs.getString('id');

    Stream stream = Firestore.instance
        .collection("users")
        .document(prefs.getString('id'))
        .collection('Notes')
        .orderBy("id", descending: true)
        .snapshots();
    return stream;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: Theme.of(context).textTheme.title.copyWith(
              color: Colors.black54.withOpacity(0.4),
            ),
      ),
    );
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: snapshot.data,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              backgroundColor:
                                  isSwitched ? Colors.white : Colors.black,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Loading Notes...",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: isSwitched
                                          ? Colors.white
                                          : Colors.black),
                            ),
                          ],
                        );
                      }
                      if (snapshot.data.documents != null &&
                          snapshot.data.documents.isNotEmpty) {
                        List<DocumentSnapshot> b1 = query.isEmpty
                            ? snapshot.data.documents
                            : snapshot.data.documents
                                .where((element) => element.data['title']
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();
                        return b1.isNotEmpty
                            ? StaggeredGridView.countBuilder(
                                itemBuilder: (context, int index) {
                                  DocumentSnapshot doc = b1[index];
                                  QuillController _controller =
                                      new QuillController.basic();

                                  var myJSON = jsonDecode(doc['content']);
                                  _controller = new QuillController(
                                      document: Document.fromJson(myJSON),
                                      selection:
                                          TextSelection.collapsed(offset: 0));
                                  String colorString = doc['color']
                                      .toString(); // Color(0x12345678)
                                  String valueString = colorString
                                      .split('(0x')[1]
                                      .split(')')[0]; // kind of hacky..
                                  int value = int.parse(valueString, radix: 16);
                                  Color otherColor = new Color(value);
                                  //print(doc['id']);
                                  return (doc != null &&
                                          b1 != null &&
                                          b1.isNotEmpty)
                                      ? InkWell(
                                          onTap: () {
                                            var down =
                                                Get.put<UpdateNoteController>(
                                                        UpdateNoteController())
                                                    .upateNoteModel;
                                            Get.put<UpdateNoteController>(
                                                    UpdateNoteController())
                                                .isUpdate
                                                .value = true;
                                            DateTime dateTime =
                                                doc["date"].toDate();
                                            down.id = doc['id'].toString();
                                            down.title = doc['title'];
                                            down.content = doc['content'];
                                            down.color = doc['color'];
                                            down.date = dateTime;

                                            Get.put<UpdateNoteController>(
                                                    UpdateNoteController())
                                                .update();

                                            Get.to(HomePage());
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: otherColor == null
                                                  ? Colors.lightBlueAccent
                                                      .withOpacity(0.1)
                                                  : otherColor,
                                              // borderRadius: BorderRadius.circular(30.0),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        doc['title'],
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        softWrap: true,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6,
                                                      ),
                                                      flex: 3,
                                                    ),
                                                    PopupMenuButton<String>(
                                                      onSelected: (value) {
                                                        switch (value) {
                                                          case 'Edit':
                                                            var down = Get.put<
                                                                        UpdateNoteController>(
                                                                    UpdateNoteController())
                                                                .upateNoteModel;

                                                            Get.put<UpdateNoteController>(
                                                                    UpdateNoteController())
                                                                .isUpdate
                                                                .value = true;
                                                            DateTime dateTime =
                                                                doc["date"]
                                                                    .toDate();

                                                            down.id = doc['id']
                                                                .toString();
                                                            down.title =
                                                                doc['title'];
                                                            down.content =
                                                                doc['content'];
                                                            down.color =
                                                                doc['color'];
                                                            down.date =
                                                                dateTime;

                                                            Get.put<UpdateNoteController>(
                                                                    UpdateNoteController())
                                                                .update();

                                                            Get.to(HomePage());
                                                            break;
                                                          case 'Delete':
                                                            Database()
                                                                .deleteNotes(
                                                                    doc['id']);
                                                            break;
                                                          case 'Share':
                                                            break;
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        return {
                                                          'Edit',
                                                          'Delete',
                                                          'Share'
                                                        }.map((String choice) {
                                                          return PopupMenuItem<
                                                              String>(
                                                            value: choice,
                                                            child: Text(
                                                              choice,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1,
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                      _controller.document
                                                          .toPlainText(),
                                                      maxLines: 3,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6),
                                                ),
                                                Text(
                                                  _ago(doc['date']).toString(),
                                                  textAlign: TextAlign.right,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Image.asset(
                                                  'assets/notes.png',
                                                  width: 250,
                                                  height: 250,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'No ${query}\tnotes Found',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6
                                                        .copyWith(fontSize: 16),
                                                  ),
                                                  Icon(
                                                    Icons.add_circle,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                },
                                staggeredTileBuilder: (int index) =>
                                    new StaggeredTile.count(2, 2),
                                //index.isEven ? 2 : 1.5
                                mainAxisSpacing: 20.0,
                                crossAxisSpacing: 5.0,
                                itemCount: b1.length,
                                crossAxisCount: 4,
                                padding: const EdgeInsets.all(10),
                              )
                            : Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Image.asset(
                                        'assets/notes.png',
                                        width: 250,
                                        height: 250,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'No ${query}\tnotes Found',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(
                                                fontSize: 16,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                      }

                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                            child: CircularProgressIndicator(
                          // color: Color(0xff8DB646),
                          backgroundColor: Color(0xff8DB646),
                        ));
                      } else {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Image.asset(
                                  'assets/notes.png',
                                  width: 250,
                                  height: 250,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start creating  your own Notes by clicking on ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.add_circle,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
          future: getData(),
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: snapshot.data,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              backgroundColor:
                                  isSwitched ? Colors.white : Colors.black,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Loading Notes...",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5
                                  .copyWith(
                                      color: isSwitched
                                          ? Colors.white
                                          : Colors.black),
                            ),
                          ],
                        );
                      } else if (snapshot.data.documents.isNotEmpty) {
                        return StaggeredGridView.countBuilder(
                          itemBuilder: (context, int index) {
                            QuillController _controller =
                                new QuillController.basic();

                            var doc = snapshot.data.documents[index];
                            var myJSON = jsonDecode(doc['content']);
                            _controller = new QuillController(
                                document: Document.fromJson(myJSON),
                                selection: TextSelection.collapsed(offset: 0));
                            String colorString =
                                doc['color'].toString(); // Color(0x12345678)
                            String valueString = colorString
                                .split('(0x')[1]
                                .split(')')[0]; // kind of hacky..
                            int value = int.parse(valueString, radix: 16);
                            Color otherColor = new Color(value);
                            print(doc['id']);
                            return InkWell(
                              onTap: () {
                                var down = Get.put<UpdateNoteController>(
                                        UpdateNoteController())
                                    .upateNoteModel;
                                Get.put<UpdateNoteController>(
                                        UpdateNoteController())
                                    .isUpdate
                                    .value = true;
                                DateTime dateTime = doc["date"].toDate();
                                down.id = doc['id'].toString();
                                down.title = doc['title'];
                                down.content = doc['content'];
                                down.color = doc['color'];
                                down.date = dateTime;

                                Get.put<UpdateNoteController>(
                                        UpdateNoteController())
                                    .update();

                                Get.to(HomePage());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: otherColor == null
                                      ? Colors.lightBlueAccent.withOpacity(0.1)
                                      : otherColor,
                                  // borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            doc['title'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: true,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                          flex: 3,
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'Edit':
                                                var down = Get.put<
                                                            UpdateNoteController>(
                                                        UpdateNoteController())
                                                    .upateNoteModel;

                                                Get.put<UpdateNoteController>(
                                                        UpdateNoteController())
                                                    .isUpdate
                                                    .value = true;
                                                DateTime dateTime =
                                                    doc["date"].toDate();

                                                down.id = doc['id'].toString();
                                                down.title = doc['title'];
                                                down.content = doc['content'];
                                                down.color = doc['color'];
                                                down.date = dateTime;

                                                Get.put<UpdateNoteController>(
                                                        UpdateNoteController())
                                                    .update();

                                                Get.to(HomePage());
                                                break;
                                              case 'Delete':
                                                Database()
                                                    .deleteNotes(doc['id']);
                                                break;
                                              case 'Share':
                                                break;
                                            }
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return {'Edit', 'Delete', 'Share'}
                                                .map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: choice,
                                                child: Text(
                                                  choice,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1,
                                                ),
                                              );
                                            }).toList();
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                          _controller.document.toPlainText(),
                                          maxLines: 3,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6),
                                    ),
                                    Text(
                                      _ago(doc['date']).toString(),
                                      textAlign: TextAlign.right,
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          staggeredTileBuilder: (int index) =>
                              new StaggeredTile.count(2, 2),
                          //index.isEven ? 2 : 1.5
                          mainAxisSpacing: 20.0,
                          crossAxisSpacing: 5.0,
                          itemCount: snapshot.data.documents.length,
                          crossAxisCount: 4,
                          padding: const EdgeInsets.all(10),
                        );
                      } else {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Image.asset(
                                  'assets/notes.png',
                                  width: 250,
                                  height: 250,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Start creating  your own Notes by clicking on ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .copyWith(fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.add_circle,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              );
            } else {
              return CircularProgressIndicator();
            }
          },
          future: getData(),
        ),
      ],
    );
  }
}
