import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/customNavbar.dart';

class LettersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // number of tabs
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: AppBar(
              backgroundColor: Colors.white,
              titleSpacing: 0,
              elevation: 0,
              title: null,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Theme(
                  data: ThemeData(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                    child: TabBar(
                      indicatorColor: Color(0xFF2B6ED3),
                      labelColor: Color(0xFF2B6ED3),
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(
                          text: "Latest News 🗞️",
                        ),
                        Tab(
                          text: "Front Pages 📰",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              toolbarHeight: 10,
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // first tab content
            Column(
              children: [],
            ),
            // second tab content
            Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  child: Text(
                    'EDIT FAVOURITE FRONT PAGES',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 86, 85, 85),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Colors.grey),
                    ),
                  ),
                  onPressed: () {
                    var controller = Get.put(MyController());
                    controller.currentIndex.value = 4;

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => ProfileScreen()),
                    // );
                  },
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
