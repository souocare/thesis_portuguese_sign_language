import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final client = http.Client();

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color backgroundColor = Color.fromARGB(0, 255, 255, 255).withOpacity(0.5);

  String letter = ''; //lat lisbon

  @override
  void initState() {
    super.initState();
    generateRandomLetter();
  }

  void generateRandomLetter() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    setState(() {
      letter = alphabet[random.nextInt(alphabet.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Bom dia!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Wrap(
                        children: [
                          Text(
                            'Bem-vindo/a de volta. Estarei aqui sempre que precisares de ajuda sobre Língua Gestual Portuguesa.',
                            style: TextStyle(
                              color: Color(0xFF5B5B5B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // logo
              Image.asset('assets/logoapp.png', height: 150),

              const SizedBox(height: 30),

              // welcome back, you've been missed!
              Text(
                'Letra do Dia',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 25),
              if (letter.isNotEmpty) ...[
                Image.asset('assets/letters/bothways/letter_${letter}.png',
                    height: 150),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'A letra de hoje é:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    '${letter.toUpperCase()}',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  generateRandomLetter();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2796B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Gerar nova letra",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
