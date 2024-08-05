import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:transparent_image/transparent_image.dart';

class LettersScreen extends StatelessWidget {
  final letters = [
    {"letter": "A", "imagePath": "assets/letters/oneway/letter_a.png"},
    {"letter": "B", "imagePath": "assets/letters/oneway/letter_b.png"},
    {"letter": "C", "imagePath": "assets/letters/oneway/letter_c.png"},
    {"letter": "D", "imagePath": "assets/letters/oneway/letter_d.png"},
    {"letter": "E", "imagePath": "assets/letters/oneway/letter_e.png"},
    {"letter": "F", "imagePath": "assets/letters/oneway/letter_f.png"},
    {"letter": "G", "imagePath": "assets/letters/oneway/letter_g.png"},
    {"letter": "H", "imagePath": "assets/letters/oneway/letter_h.png"},
    {"letter": "I", "imagePath": "assets/letters/oneway/letter_i.png"},
    {"letter": "J", "imagePath": "assets/letters/oneway/letter_j.png"},
    {"letter": "K", "imagePath": "assets/letters/oneway/letter_k.png"},
    {"letter": "L", "imagePath": "assets/letters/oneway/letter_l.png"},
    {"letter": "M", "imagePath": "assets/letters/oneway/letter_m.png"},
    {"letter": "N", "imagePath": "assets/letters/oneway/letter_n.png"},
    {"letter": "O", "imagePath": "assets/letters/oneway/letter_o.png"},
    {"letter": "P", "imagePath": "assets/letters/oneway/letter_p.png"},
    {"letter": "Q", "imagePath": "assets/letters/oneway/letter_q.png"},
    {"letter": "R", "imagePath": "assets/letters/oneway/letter_r.png"},
    {"letter": "S", "imagePath": "assets/letters/oneway/letter_s.png"},
    {"letter": "T", "imagePath": "assets/letters/oneway/letter_t.png"},
    {"letter": "U", "imagePath": "assets/letters/oneway/letter_u.png"},
    {"letter": "V", "imagePath": "assets/letters/oneway/letter_v.png"},
    {"letter": "W", "imagePath": "assets/letters/oneway/letter_w.png"},
    {"letter": "X", "imagePath": "assets/letters/oneway/letter_x.png"},
    {"letter": "Y", "imagePath": "assets/letters/oneway/letter_y.png"},
    {"letter": "Z", "imagePath": "assets/letters/oneway/letter_z.png"},
    // Add all other letters here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letter = letters[index];
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Stack(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    child: PhotoView(
                                      backgroundDecoration:
                                          BoxDecoration(color: Colors.white),
                                      imageProvider: AssetImage(
                                        'assets/letters/bothways/letter_${letter['letter']?.toLowerCase()}.png',
                                      ),
                                      loadingBuilder: (BuildContext context,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return const SizedBox();
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      initialScale:
                                          PhotoViewComputedScale.contained,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              letter['imagePath']!,
                              width: 70,
                              height: 70,
                            ),
                            SizedBox(
                                height:
                                    10), // Add some space between image and text
                            Text(letter['letter']!),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
