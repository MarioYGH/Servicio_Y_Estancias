import numpy as np
import cv2
import gradio as gr
import os
import psutil
import webbrowser
from tensorflow.lite.python.interpreter import Interpreter

# Liberar puertos ocupados por procesos anteriores
def liberar_puerto(puerto):
    for proc in psutil.process_iter(attrs=['pid', 'name', 'connections']):
        for conn in proc.info['connections']:
            if conn.laddr.port == puerto:
                print(f" Cerrando proceso {proc.info['name']} (PID: {proc.info['pid']}) en el puerto {puerto}")
                os.system(f"taskkill /PID {proc.info['pid']} /F")

# Intenta liberar el puerto 7860 si está ocupado
liberar_puerto(7860)

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

# Iniciar la aplicación sin conflictos de puertos
launch_result = interface.launch(server_name="0.0.0.0", server_port=None, share=True)

if isinstance(launch_result, str):  # Si devuelve una URL
    url = launch_result
elif isinstance(launch_result, tuple):  # Si devuelve una tupla
    url = launch_result[1]  # Tomamos la URL pública (segunda posición)
else:
    url = None

# Abrir la URL solo si se obtuvo correctamente
if url:
    print("Abriendo en el navegador: {url}")
    webbrowser.open(url)
else:
    print("No se pudo obtener la URL de Gradio.")


# Abrir la URL automáticamente en el navegador
print(" Abriendo en el navegador: {url}")
webbrowser.open(url)
