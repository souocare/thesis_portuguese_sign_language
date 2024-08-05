# Application for Translating Portuguese Sign Language (LGP) to Portuguese Using Artificial Intelligence
## Overview
This project, developed as part of my master's thesis at ISEL in Lisbon, Portugal with the portuguese name "Aplicação de Tradução de Língua Gestual Portuguesa (LGP) para Português com Recurso a Inteligência Artificial", aims to create a system for translating Portuguese Sign Language (LGP) to Portuguese using artificial intelligence. The project is divided into two main parts:

1. **CNN Model for Sign Language Recognition**: A Convolutional Neural Network (CNN) is trained to recognize sign language letters. Due to the limited dataset for LGP, the initial model is trained on American Sign Language (ASL) datasets and then fine-tuned for LGP using transfer learning.

1. **Flutter Application**: A mobile app built with Flutter that leverages the trained CNN model to provide real-time sign language recognition and translation.

## Project Structure
### Part 1: CNN Model Training
**Objective**: Train a CNN model for recognizing sign language letters.

**Steps**:

1. Training with ASL Data:
    - Datasets Used:
        - [ASL Alphabet Dataset](https://www.kaggle.com/datasets/grassknoted/asl-alphabet)
        - [Synthetic ASL Alphabet Dataset](https://www.kaggle.com/datasets/lexset/synthetic-asl-alphabet)
    - **Details**: Train the CNN model on these datasets to achieve high accuracy for ASL sign recognition. The model is trained using TensorFlow and Keras. It was joined 2 datasets to increase the number of samples for training.

2. Transfer Learning for PSL:
    - **Objective**: Fine-tune the pre-trained ASL model to recognize LGP signs.
    - **Dataset**: A LGP sign dataset is used for fine-tuning. 
    - **Details**: The ASL model is adapted for LGP through transfer learning to ensure effective recognition of LGP signs.

### Part 2: Flutter Mobile App
**Objective**: Develop a Flutter application to use the trained CNN model for real-time sign language recognition.

#### Features:

- **Real-Time Recognition & Translation**: The main feature of the application is to capture and recognize LGP signs through the mobile camera, displaying the translated text in Portuguese.