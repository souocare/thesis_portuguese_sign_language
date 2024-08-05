import 'package:get/get.dart';
import 'package:lgp_signlanguage_app/views/translate_page.dart';

import '../views/home_page.dart';
import '../views/letters_page.dart';
import '../views/camera_page.dart';

class MyController extends GetxController {
  RxInt currentIndex = 0.obs;

  var iconPathsFinal = [
    "assets/iconsbar/casa_logo_selected.png",
    "assets/iconsbar/fotografia_logo.png",
    "assets/iconsbar/letras_logo.png",
    "assets/iconsbar/traduzir_logo.png",
  ].obs;

  var notSelectedIconPaths = [
    "assets/iconsbar/casa_logo.png",
    "assets/iconsbar/fotografia_logo.png",
    "assets/iconsbar/letras_logo.png",
    "assets/iconsbar/traduzir_logo.png",
  ].obs;
  var selectedIconPaths = [
    "assets/iconsbar/casa_logo.png",
    "assets/iconsbar/fotografia_logo_selected.png",
    "assets/iconsbar/letras_logo_selected.png",
    "assets/iconsbar/traduzir_logo_selected.png",
  ].obs;

  void navbarIndexsFunc(index) {
    currentIndex.value = index;
    // Set the selected icon path for the "Weather" option
    if (currentIndex.value == 0) {
      iconPathsFinal[0] = selectedIconPaths[0];
    } else {
      iconPathsFinal[0] = notSelectedIconPaths[0];
    }
    if (currentIndex.value == 1) {
      iconPathsFinal[1] = selectedIconPaths[1];
    } else {
      iconPathsFinal[1] = notSelectedIconPaths[1];
    }
    if (currentIndex.value == 2) {
      iconPathsFinal[2] = selectedIconPaths[2];
    } else {
      iconPathsFinal[2] = notSelectedIconPaths[2];
    }
    if (currentIndex.value == 3) {
      iconPathsFinal[3] = selectedIconPaths[3];
    } else {
      iconPathsFinal[3] = notSelectedIconPaths[3];
    }
  }

//screen move with change index
  var screens = [
    HomeScreen(),
    CameraScreen(),
    LettersScreen(),
    TranslateScreen(),
  ].obs;
}
