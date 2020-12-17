import 'package:get/get.dart';
import 'package:notes/models/DarkThemePreference.dart';

class DarkThemeController extends GetxController {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  var _darkTheme = false.obs;

  bool get darkTheme1 => _darkTheme.value;

  set darkTheme1(bool value) {
    _darkTheme = value.obs;
    darkThemePreference.setDarkTheme(value);
    update();
  }

  DarkThemeController themeChangeProvider = DarkThemeController();

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme1 =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void onInit() {
    getCurrentAppTheme();
    super.onInit();
  }
}
