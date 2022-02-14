import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String email;
  String profilePic;

  UserModel({this.id, this.name, this.email, this.profilePic});

  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.documentID;
    name = doc["name"];
    email = doc["email"];
    profilePic = doc["profilePic"];
  }
}
