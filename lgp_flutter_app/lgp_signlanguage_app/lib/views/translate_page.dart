import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:diacritic/diacritic.dart'; // For normalization

import '../utils/customNavbar.dart';

class TranslateScreen extends StatefulWidget {
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  TextEditingController _textController = TextEditingController();
  List<Map<String, String>> _imagePaths = [];

  // Method to normalize the input text for image path generation
  String _normalizeText(String text) {
    // Convert accented characters to their base forms
    String normalizedText = removeDiacritics(text.toLowerCase());
    // Remove non-letter characters except for whitespace
    return normalizedText.replaceAll(RegExp(r'[^a-z ]'), '');
  }

  // Method to generate the list of image paths based on the normalized input text
  void _generateImagePaths(String text) {
    String normalizedText = _normalizeText(text);
    List<Map<String, String>> paths = [];
    for (int i = 0; i < normalizedText.length; i++) {
      String letter = normalizedText[i];
      if (letter != ' ') {
        // Ignore spaces
        paths.add({
          'small': 'assets/letters/oneway/letter_${letter}.png',
          'large': 'assets/letters/bothways/letter_${letter}.png',
        });
      }
    }
    setState(() {
      _imagePaths = paths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Escreva a palavra ou frase que quer traduzir',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) {
                _generateImagePaths(
                    text); // Generate images when enter is pressed
              },
              // Ensure the text field displays the special characters
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _generateImagePaths(_textController
                    .text); // Generate images when button is pressed
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFF2796B), // Button color
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
              child: Text('Traduzir!'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _imagePaths.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 4 letters per row
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _imagePaths.length,
                      itemBuilder: (context, index) {
                        final imagePath = _imagePaths[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.4,
                                          child: PhotoView(
                                            backgroundDecoration: BoxDecoration(
                                                color: Colors.white),
                                            imageProvider: AssetImage(
                                              imagePath['large']!,
                                            ),
                                            loadingBuilder:
                                                (BuildContext context,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                              if (loadingProgress == null) {
                                                return const SizedBox();
                                              }
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
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
                                            initialScale: PhotoViewComputedScale
                                                .contained,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    imagePath['small']!,
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 5),
                                  Text(imagePath['small']!
                                      .split('_')
                                      .last
                                      .split('.')
                                      .first
                                      .toUpperCase()),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('Sem letras para apresentar')),
            ),
          ],
        ),
      ),
    );
  }
}
