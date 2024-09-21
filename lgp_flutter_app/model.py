import numpy as np
import tensorflow as tf
from PIL import Image
from tensorflow.keras.preprocessing import image as keras_image
import io
import matplotlib.pyplot as plt

class_labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'nothing']

# Load your model
model = tf.keras.models.load_model('/Users/souocare/Documents/Mestrado/Tese/Code/model_final_pt_v2.keras')

def preprocess_image(image_path, target_size=(128, 128)):
    """Load and preprocess the image for model prediction."""
    # Load the image
    img = keras_image.load_img(image_path, target_size=target_size)  # Change 'color_mode' based on your model requirements

    img = tf.image.flip_left_right(img)
    img = tf.image.rgb_to_grayscale(img)

    # Convert image to array
    img_array = keras_image.img_to_array(img)

    
    # Normalize the image
    img_array /= 255.0  # Scale to [0, 1]

    # Add batch dimension
    img_array = np.expand_dims(img_array, axis=0)
    
    return img_array


def predict(image_path, model):
    """Make a prediction on the image using the given model."""
    img_array = preprocess_image(image_path)
    plt.imshow(img_array[0].reshape(128, 128), cmap='gray')
    plt.title('Preprocessed Image')
    plt.axis('off')  # Turn off axis numbers and ticks
    plt.show()
    prediction = model.predict(img_array)
    
    # Get the index of the highest probability
    predicted_class_index = np.argmax(prediction)
    
    # Get the class label
    predicted_class_label = class_labels[predicted_class_index]
    
    # Print results
    print("Predicted Class Index:", predicted_class_index)
    print("Predicted Class Label:", predicted_class_label)
    print("Prediction Probabilities:", prediction)

if __name__ == '__main__':
    # Path to the image you want to test
    image_path = '/Users/souocare/Documents/Mestrado/Tese/Code/getphotosmac/LGP_outputdummy/B/aug_0_IMG_0513.JPG'
    predict(image_path, model)
