import numpy as np
import cv2
import gradio as gr
from tflite_runtime.interpreter import Interpreter  # Cambiar importación

# Cargar el modelo TFLite
interpreter = Interpreter(model_path="blur_classification_model.tflite")
interpreter.allocate_tensors()

# Obtener detalles de entrada y salida del modelo
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Función para preprocesar la imagen
def preprocess_image(image):
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = cv2.resize(image, (64, 64))  # Ajustar tamaño al esperado por el modelo
    image = image / 255.0  # Normalizar
    image = np.expand_dims(image, axis=0)  # Añadir dimensión batch
    return image

# Función para predecir el nivel de desenfoque
def predict_blur(image):
    preprocessed_image = preprocess_image(image)

    # Asignar la entrada al modelo
    interpreter.set_tensor(input_details[0]['index'], preprocessed_image.astype(np.float32))

    # Ejecutar la predicción
    interpreter.invoke()

    # Obtener la salida
    output_data = interpreter.get_tensor(output_details[0]['index'])
    predicted_blur_level = np.argmax(output_data)  # Nivel de desenfoque
    return f"Nivel de desenfoque: {predicted_blur_level}"

# Crear la interfaz Gradio
interface = gr.Interface(
    fn=predict_blur,
    inputs=gr.Image(type="numpy", label="Sube tu imagen"),
    outputs="text",
    title="Clasificador de Desenfoque",
    description="Sube una imagen y el modelo predirá el nivel de desenfoque."
)

# Iniciar la aplicación
interface.launch(server_name="0.0.0.0", server_port=7860)
