import os
import cv2
import numpy as np
import itertools
import mediapipe as mp
import tensorflow as tf
from flask import Flask, request, jsonify
from flask_restful import Api, Resource
import asyncio
from concurrent.futures import ThreadPoolExecutor
import serious_python  # Import serious_python

# Initialize Flask app and API
app = Flask(__name__)
api = Api(app)

# Initialize MediaPipe for hand landmarks
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=False, max_num_hands=1, min_detection_confidence=0.75)

# Load your Keras model (adjust the path to your model)
model = tf.keras.models.load_model("model34_v2imgs.keras")

# ThreadPoolExecutor for running tasks asynchronously
executor = ThreadPoolExecutor()

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
    # Convert bytes to image
    np_arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Process the image with MediaPipe to get hand landmarks
    results = hands.process(img_rgb)

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
            return predictions[0].tolist()  # Convert to list for JSON serialization
    return None

class PredictHandLandmarks(Resource):
    async def post(self):
        image = request.data  # Reading image data from the request body

        # Run prediction asynchronously
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(executor, process_image_and_predict, image)
        
        if result is not None:
            return jsonify({"predictions": result})
        else:
            return {"error": "No hand landmarks detected"}, 400

# Add resource to API
api.add_resource(PredictHandLandmarks, '/predict')

# Serve the Flask app using serious_python
if __name__ == '__main__':
    serious_python.serve(app)  # Serve the Flask app with serious_python
