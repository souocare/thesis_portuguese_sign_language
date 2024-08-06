from flask import Flask, request, jsonify
import numpy as np
import tensorflow as tf
from PIL import Image
import io

app = Flask(__name__)

# Load your model
model = tf.keras.models.load_model('lgp_signlanguage_app/assets/tf_model/model_final_pt.tflite')

def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes))
    image = image.resize((128, 128))  # Adjust to your model's input size
    image = np.array(image) / 255.0
    image = np.expand_dims(image, axis=0)
    return image

@app.route('/predict', methods=['POST'])
def predict():
    image_bytes = request.files['image'].read()
    image = preprocess_image(image_bytes)
    prediction = model.predict(image)
    result = prediction.tolist()
    return jsonify(result)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
