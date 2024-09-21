from flask import Flask, request, jsonify
import numpy as np
import tensorflow as tf
from PIL import Image
import io

app = Flask(__name__)

# Load your model
model = tf.keras.models.load_model('/Users/souocare/Documents/Mestrado/Tese/Code/model_final_moreimgs_97_pt.keras')

def preprocess_image(image_bytes):
    image = Image.open(io.BytesIO(image_bytes)).convert('L')  # Convert image to grayscale
    image = image.resize((128, 128))  # Adjust to your model's input size
    image.save('debug_image.jpg')  # Save the image for inspection
    image = np.array(image) / 255.0
    image = np.expand_dims(image, axis=-1)  # Add channel dimension
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    return image

@app.route('/predict', methods=['POST'])
def predict():
    try:
        image_bytes = request.data  # Read raw bytes
        image = preprocess_image(image_bytes)
        prediction = model.predict(image)
        
        # Flatten the list if it's nested (list of lists)
        prediction = prediction[0] if isinstance(prediction, list) and len(prediction) > 0 else prediction
        
        # Get the index of the highest probability
        predicted_class_index = np.argmax(prediction)
        
        print("\n\nPredicted Class Index:", predicted_class_index)
        print("Prediction Probabilities:", prediction)
        
        return jsonify({'prediction': int(predicted_class_index)})  # Send back the predicted class index
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2468)
