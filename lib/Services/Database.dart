import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/route_manager.dart';
import 'package:notes/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Database {
  final Firestore firestore = Firestore.instance;

  Future<bool> createNewUser(UserModel userModel) async {
    try {
      await firestore
          .collection("users")
          .document(userModel.id)
          .setData({"name": userModel.name, "email": userModel.email});
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<UserModel> getUser(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      DocumentSnapshot doc =
          await firestore.collection("users").document(uid).get();
      print('uid' + uid);

      prefs.setString('name', UserModel.fromDocumentSnapshot(doc).name);
      prefs.setString('id', uid.toString());
      return UserModel.fromDocumentSnapshot(doc);
    } catch (e) {
      print('Error checking' + e.toString());
      rethrow;
    }
  }

  Future addNotes(title, content, color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = await Firestore.instance
        .collection('users')
        .document(prefs.getString('id'))
        .collection('Notes')
        .orderBy("id", descending: true)
        .getDocuments();
    print('total notes presented : ' + data.documents.length.toString());
    DateTime date = DateTime.now();

    int getLastID =
        data.documents.isEmpty ? 1 : int.parse(data.documents[0]['id']);
    print('last note id : ' + getLastID.toString());

    int id = getLastID == 0 ? getLastID + 1 : getLastID + 1;
    print('Assigning new id : ' + id.toString());
    String searchKey = title.substring(0, 1).toUpperCase();

    try {
      await Firestore.instance
          .collection('users')
          .document(prefs.getString('id'))
          .collection('Notes')
          .document(id.toString())
          .setData({
        "id": id.toString(),
        "name": prefs.getString('name'),
        "title": title,
        "date": date,
        "content": content,
        "color": color.toString(),
        "searchKey": searchKey,
      });
    } catch (e) {
      print(e);
    }
  }

  deleteNotes(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await Firestore.instance
          .collection("users")
          .document(prefs.getString('id'))
          .collection('Notes')
          .document(id.toString())
          .delete();

      Get.snackbar('Deleted Successfully', '',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  updateNotes({id, title, content, date, color}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      await firestore
          .collection("users")
          .document(prefs.getString('id'))
          .collection('Notes')
          .document('$id')
          .setData({
        "id": id,
        "name": prefs.getString('name'),
        "title": title,
        "date": date,
        "content": content,
        "color": color.toString(),
      });
    } catch (e) {
      Get.snackbar('Error', "$e");
      print(e);
      rethrow;
    }
  }

  void addCategories(title, content) async {}

  void removeCategories() async {}

  void updateCategories() async {}

  void readCategories() async {}
}
