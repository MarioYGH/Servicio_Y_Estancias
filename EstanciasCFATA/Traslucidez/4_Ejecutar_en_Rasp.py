import numpy as np
import cv2
import gradio as gr
from tflite_runtime.interpreter import Interpreter

# Cargar el modelo TFLite
interpreter = Interpreter(model_path="blur_classification_model.tflite")
interpreter.allocate_tensors()

# Obtener detalles de entrada y salida del modelo
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Función para preprocesar la imagen
def preprocess_image(image):
    if image is None:
        return None
    
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)  # OpenCV usa BGR, Gradio da RGB
    image = cv2.resize(image, (64, 64))  # Ajustar tamaño al esperado por el modelo
    image = image.astype(np.float32) / 255.0  # Normalizar
    image = np.expand_dims(image, axis=0)  # Añadir dimensión batch
    return image

# Función para predecir el nivel de desenfoque
def predict_blur(image):
    preprocessed_image = preprocess_image(image)
    if preprocessed_image is None:
        return "Error: No se recibió una imagen válida."

    # Asignar la entrada al modelo
    interpreter.set_tensor(input_details[0]['index'], preprocessed_image)

    # Ejecutar la predicción
    interpreter.invoke()

    # Obtener la salida
    output_data = interpreter.get_tensor(output_details[0]['index'])
    predicted_blur_level = np.argmax(output_data)  # Nivel de desenfoque
    return f"Nivel de desenfoque: {predicted_blur_level}"

# Crear la interfaz Gradio con opción de webcam
interface = gr.Interface(
    fn=predict_blur,
    inputs=gr.Camera(label="Captura desde la Webcam"),
    outputs="text",
    title="Clasificador de Desenfoque",
    description="Captura una imagen con tu webcam y el modelo predecirá el nivel de desenfoque."
)

# Iniciar la aplicación con localhost
interface.launch(server_name="localhost", server_port=7860, share=True)
