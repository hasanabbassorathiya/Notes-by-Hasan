import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:notes/Controller/Styles.dart';
import 'package:notes/Controller/updateNoteController.dart';
import 'package:notes/NotesCard.dart';
import 'package:notes/Services/Database.dart';
import 'package:notes/models/NotesModel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'Controller/authController.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  List<Note> notes = [];
  SharedPreferences prefs;
  Stream stream, searchStream;
  bool isSwitched = false;
  String name = " ";
  String fullname = '';
  var id;

  RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

  getData() async {
    prefs = await SharedPreferences.getInstance();
    fullname = prefs.getString('name') ?? 'User';
    id = prefs.getString('id');
    setState(() {
      stream = Firestore.instance
          .collection("users")
          .document(prefs.getString('id'))
          .collection('Notes')
          .orderBy("id", descending: true)
          .snapshots();
      isSwitched = prefs.getBool('isDarkTheme') ?? false;
    });
    _refreshController.loadComplete();
  }

  getMode() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      isSwitched = !isSwitched;
      Get.changeTheme(Styles.themeData(isSwitched, context));
    });
  }

  final updateController = UpdateNoteController();

  _ago(Timestamp t) {
    return timeago.format(t.toDate(), locale: 'en_long', allowFromNow: true);
  }

  @override
  void initState() {
    getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      enableLoadingWhenFailed: true,
      child: Scaffold(
        primary: true,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          primary: true,
          title: Text(
            'Notes',
            style: Theme.of(context).textTheme.headline5,
            overflow: TextOverflow.ellipsis,
          ),
          elevation: 0,
          actions: [
            IconButton(
              color: Theme.of(context).iconTheme.color,
              icon: !isSwitched
                  ? Icon(Icons.wb_sunny)
                  : Icon(Icons.nights_stay_outlined),
              onPressed: () {
                getMode();
              },
            ),
            FlatButton(
                onPressed: () {
                  Get.find<AuthController>().signOut();
                },
                child: Icon(Icons.exit_to_app)),
          ],
        ),
        // backgroundColor: Theme.of(context).backgroundColor,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Get.put<UpdateNoteController>(UpdateNoteController())
                .isUpdate
                .value = false;
            Get.to(NoteEditor());
          },
        ),
        body: SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          physics: BouncingScrollPhysics(),
          onRefresh: () async {
            //monitor fetch data from network
            await Future.delayed(Duration(milliseconds: 1000));

            if (mounted) setState(() {});
            await getData();
            _refreshController.refreshCompleted();
          },
          onLoading: () async {
            //monitor fetch data from network
            await Future.delayed(Duration(milliseconds: 180));

            if (mounted) setState(() {});
            await getData();
            _refreshController.loadFailed();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Hello, ' + "$fullname",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    // Switch(
                    //   value: isSwitched,
                    //   onChanged: (value) async {
                    //     prefs = await SharedPreferences.getInstance();
                    //
                    //     setState(() {
                    //       isSwitched = value;
                    //
                    //       prefs.setBool('isDarkTheme', value);
                    //       Get.changeTheme(
                    //           Styles.themeData(isSwitched, context));
                    //
                    //       print(isSwitched);
                    //     });
                    //   },
                    //   activeTrackColor: Color(0xFF171C26),
                    //   activeColor: Colors.white,
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 10,
                  bottom: 20,
                ),
                child: Column(children: [
                  Card(
                    child: TextField(
                      onTap: () {},
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: isSwitched ? Colors.white : Colors.black,
                          ),
                          hintText: 'Search...',
                          hintStyle: Theme.of(context).textTheme.subtitle1),
                      onChanged: (val) {
                        setState(() {
                          name = val.isEmpty ? " " : val;
                        });
                      },
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .document(id)
                      .collection('Notes')
                      .where("searchKey",
                          isEqualTo: name.substring(0, 1).toUpperCase())
                      .snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot doc =
                                  snapshot.data.documents[index];
                              String colorString =
                                  doc['color'].toString(); // Color(0x12345678)
                              String valueString = colorString
                                  .split('(0x')[1]
                                  .split(')')[0]; // kind of hacky..
                              int value = int.parse(valueString, radix: 16);
                              Color otherColor = new Color(value);
                              return Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: otherColor == null
                                      ? Colors.lightBlueAccent.withOpacity(0.1)
                                      : otherColor,
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child:
                                    Text(index.toString() + '.' + doc['title']),
                              );
                            },
                          );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: StreamBuilder<QuerySnapshot>(
                    stream: stream,
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
                            var doc = snapshot.data.documents[index];

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
                                setState(() {
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
                                  print(updateController.upateNoteModel.title);

                                  updateController.update();
                                });

                                Get.to(NoteEditor());
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

                                                print(updateController
                                                    .upateNoteModel.title);

                                                updateController.update();

                                                Get.to(NoteEditor());
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
                                      child: Text(doc['content'],
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
              ),
            ],
          ),
        ),
      ),
      headerBuilder: () => WaterDropMaterialHeader(
        distance: 30.0,
        backgroundColor:
            isSwitched ? Theme.of(context).accentColor : Colors.blueGrey,
      ),
      footerTriggerDistance: 15.0,
    );
  }
}
