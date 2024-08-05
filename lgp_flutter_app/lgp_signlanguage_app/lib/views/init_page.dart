import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/customNavbar.dart';

class BottomNavBarWrapper extends StatefulWidget {
  @override
  _BottomNavBarWrapperState createState() => _BottomNavBarWrapperState();
}

class _BottomNavBarWrapperState extends State<BottomNavBarWrapper> {
  var questionIndex = 0;

  void answerQuestion() {
    setState(() {
      questionIndex = questionIndex + 1;
    });
    print("Answer chosen!");
  }

  var controller = Get.put(MyController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(() => controller.screens[controller.currentIndex.value]),
        bottomNavigationBar: Obx(
          () => Container(
            padding: EdgeInsets.symmetric(
                vertical: 20, horizontal: 40), // Adjust for centering
            decoration: BoxDecoration(
              color: Colors.white, // Change color as needed
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFF2796B), // Border color
                  width: 2, // Border width
                ),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: controller.currentIndex.value,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedItemColor:
                    Color(0xFF5B5B5B), // Set the color for selected labels
                unselectedItemColor: Color.fromARGB(
                    255, 122, 122, 122), // Set the color for unselected labels
                onTap: (index) => controller.navbarIndexsFunc(index),
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(controller.iconPathsFinal[0],
                        width: 40, height: 40),
                    label: "Casa",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(controller.iconPathsFinal[1],
                        width: 40, height: 40),
                    label: "Câmara",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(controller.iconPathsFinal[2],
                        width: 40, height: 40),
                    label: "Letras",
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(controller.iconPathsFinal[3],
                        width: 40, height: 40),
                    label: "Traduzir",
                  ),
                ],
                backgroundColor: Color.fromARGB(255, 238, 237, 237),
              ),
            ),
          ),
        ));
  }
}

class InitPage extends StatefulWidget {
  @override
  State<InitPage> createState() => _LoggedInState();
}

class _LoggedInState extends State<InitPage> {
  var questionIndex = 0;

  void answerQuestion() {
    setState(() {
      questionIndex = questionIndex + 1;
    });
    print("Answer chosen!");
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavBarWrapper();
  }
}
