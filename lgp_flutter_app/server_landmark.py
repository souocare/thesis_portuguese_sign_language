import io
import os
import cv2
import numpy as np
import itertools
import mediapipe as mp
import tensorflow as tf
from flask import Flask, request, jsonify
from PIL import Image

# Initialize Flask app and API
app = Flask(__name__)

class_labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'nothing']
# Initialize MediaPipe for hand landmarks
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True, max_num_hands=1, min_detection_confidence=0.75)

# Load your Keras model (adjust the path to your model)
model = tf.keras.models.load_model("mediapipe_lgp_final_final.keras")

def calculate_distances(landmarks):
    distances = []
    num_landmarks = len(landmarks) // 3
    for i, j in itertools.combinations(range(num_landmarks), 2):
        dist = np.sqrt(
            (landmarks[3*i] - landmarks[3*j])**2 +
            (landmarks[3*i+1] - landmarks[3*j+1])**2 +
            (landmarks[3*i+2] - landmarks[3*j+2])**2
        )
        distances.append(dist)
    return distances

def calculate_angle(a, b, c):
    ab = b - a
    bc = c - b
    cosine_angle = np.dot(ab, bc) / (np.linalg.norm(ab) * np.linalg.norm(bc))
    angle = np.arccos(cosine_angle)
    return np.degrees(angle)

def calculate_all_angles(landmarks):
    angles = []
    num_landmarks = len(landmarks) // 3
    for i in range(1, num_landmarks-1):
        a = np.array([landmarks[3*(i-1)], landmarks[3*(i-1)+1], landmarks[3*(i-1)+2]])
        b = np.array([landmarks[3*i], landmarks[3*i+1], landmarks[3*i+2]])
        c = np.array([landmarks[3*(i+1)], landmarks[3*(i+1)+1], landmarks[3*(i+1)+2]])
        angles.append(calculate_angle(a, b, c))
    return angles

def process_image_and_predict(image_bytes):
    # Open the image from bytes using PIL
    try:
        image = Image.open(io.BytesIO(image_bytes))
        # Convert PIL Image to a format that OpenCV can work with
        img = np.array(image)
        # If the image is grayscale, convert it to a 3-channel image
        if len(img.shape) == 2:
            img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
        # Convert the image to RGB format (OpenCV loads images in BGR by default)
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        # Process the image with MediaPipe to get hand landmarks
        results = hands.process(img_rgb)
        print(results)

        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                # Extract landmark coordinates
                landmarks = []
                for lm in hand_landmarks.landmark:
                    landmarks.extend([lm.x, lm.y, lm.z])
                
                # Calculate distances and angles
                distances = calculate_distances(landmarks)
                angles = calculate_all_angles(landmarks)
                
                # Combine landmarks, distances, and angles into one feature set
                features = np.concatenate([landmarks, distances, angles])
                
                # Make a prediction (adjust shape for model input)
                features = np.expand_dims(features, axis=0)
                predictions = model.predict(features)
                print(predictions)
                return predictions[0].tolist()  # Convert to list for JSON serialization
        print("erro nao hands")
        return "erro nao hands"
    except Exception as e:
        print(e.message)
        return "erro geral"


def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes))  # Convert image to grayscale
    return image

@app.route('/predict', methods=['POST'])
def predict():
    try:
        image_bytes = request.data  # Read raw bytes
        print(f"Received data: {image_bytes[:100]}")  # Print the first 100 bytes for debugging
        prediction = process_image_and_predict(image_bytes)

        if prediction is None:
            return jsonify({'error': 'No hand landmarks detected'}), 400
        
        # Get the index of the highest probability
        predicted_class_index = np.argmax(prediction)# Get the class label
        predicted_class_label = class_labels[predicted_class_index]
        print(predicted_class_label)
        
        print("\n\nPredicted Class Index:", predicted_class_index)
        print("Prediction Probabilities:", prediction)
        
        return jsonify({'prediction': predicted_class_label})  # Send back the predicted class index
    except Exception as e:
        return jsonify({'error': str(e)}), 400


# class PredictHandLandmarks(Resource):
#     def post(self):
#         image = request.data  # Reading image data from the request body

#         # Run prediction asynchronously using run_in_executor
#         loop = asyncio.new_event_loop()
#         asyncio.set_event_loop(loop)
#         result = loop.run_until_complete(loop.run_in_executor(executor, process_image_and_predict, image))
        
#         if result is not None:
#             return jsonify({"predictions": result})
#         else:
#             return {"error": "No hand landmarks detected"}, 400


# # Add resource to API
# api.add_resource(PredictHandLandmarks, '/predict')

# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2468, debug=True)
