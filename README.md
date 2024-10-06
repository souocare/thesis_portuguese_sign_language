# Application for Translating Portuguese Sign Language (LGP) to Portuguese Using Artificial Intelligence

## Overview

This project, developed as part of my master's thesis at ISEL in Lisbon, Portugal, titled "Aplicação de Tradução de Língua Gestual Portuguesa (LGP) para Português com Recurso a Inteligência Artificial", aims to create a system for translating Portuguese Sign Language (LGP) to Portuguese using artificial intelligence. The project includes a mobile application that integrates two distinct models for real-time gesture recognition, allowing flexibility based on the user's environment and connectivity.

## Project Structure

### Part 1: Gesture Recognition Models

**Objective**: Implement two complementary models for recognizing the letters of the Portuguese Sign Language (LGP), using artificial intelligence.

#### Model 1: CNN Model via Tensorflow Lite

- **Architecture**: MobileNetV2 Convolutional Neural Network + small custom model (CNN)
- **Functionality**: The CNN model is used to recognize the gestures based on images captured by the mobile camera.
- **Optimization**: The model is converted to TensorFlow Lite for optimized performance on mobile devices, allowing for offline gesture recognition.
- **Strengths**: Offers fast, real-time recognition with low latency on more powerful devices. However, it may struggle with more complex gestures on less capable devices.
  
#### Model 2: MediaPipe + MLP via Flask Server

- **Architecture**: MediaPipe for hand landmark detection combined with a Multilayer Perceptron (MLP) for classification.
- **Functionality**: This model processes the 3D coordinates of 21 hand landmarks (captured via MediaPipe) to classify the gestures.
- **Server Integration**: The image is sent to a Flask server where the hand landmarks are detected and processed, returning the recognized letter to the mobile application.
- **Strengths**: More accurate for complex gestures, especially those involving intricate finger positions. However, it depends on a stable internet connection and has higher latency.

### Part 2: Flutter Mobile App

**Objective**: Develop a mobile application in Flutter that provides real-time sign language recognition for Portuguese Sign Language (LGP), utilizing the two models described above.

#### Features:

- **Real-Time Recognition & Translation**: The app captures gestures using the mobile camera, translating the recognized letters from LGP into Portuguese text.
- **Model Switching**: Users can switch between the local CNN model (TensorFlow Lite) for offline usage and the MediaPipe model for more accurate recognition when connected to the internet.
- **Educational Mode**: Provides users with an interactive tool to learn LGP gestures, displaying how to correctly gesture each letter.
- **Cross-Platform Support**: Built with Flutter, the app is compatible with both Android and iOS.


## Future Work
- **Expand Gesture Recognition**: Extend the current models to recognize more complex gestures and full words in LGP.
- **Improve Accuracy**: Continue refining the models to enhance recognition accuracy, especially in challenging conditions (e.g., low lighting, fast gestures)
- **Offline MediaPipe Implementation**:  Explore the possibility of running the MediaPipe model locally on the device to reduce latency and remove the dependency on internet connectivity.

## License
This software is licensed under the MIT License.