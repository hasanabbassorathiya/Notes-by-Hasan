import 'package:get/get.dart';
import 'package:notes/models/UserModel.dart';

class UserController extends GetxController {
  Rx<UserModel> _userModel = UserModel().obs;

  UserModel get userModel => _userModel.value;

  set userModel(UserModel value) => this._userModel.value = value;

  void clear() {
    _userModel.value = UserModel();
  }
}
