import numpy as np
import cv2
import gradio as gr
import os
import psutil
import webbrowser
import threading
import customtkinter as ctk
from tensorflow.lite.python.interpreter import Interpreter

# Configuración de la interfaz de CustomTkinter
ctk.set_appearance_mode("dark")  
ctk.set_default_color_theme("blue")

# Función para liberar el puerto si está ocupado
def liberar_puerto(puerto):
    for proc in psutil.process_iter(attrs=['pid', 'name', 'connections']):
        for conn in proc.info['connections']:
            if conn.laddr.port == puerto:
                print(f" Cerrando proceso {proc.info['name']} (PID: {proc.info['pid']}) en el puerto {puerto}")
                os.system(f"taskkill /PID {proc.info['pid']} /F")

# Función para ejecutar la aplicación Gradio
def ejecutar_gradio():
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
        image = cv2.resize(image, (64, 64))
        image = image / 255.0
        image = np.expand_dims(image, axis=0)
        return image

    # Función para predecir el nivel de desenfoque
    def predict_blur(image):
        preprocessed_image = preprocess_image(image)
        interpreter.set_tensor(input_details[0]['index'], preprocessed_image.astype(np.float32))
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])
        predicted_blur_level = np.argmax(output_data)
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
    launch_result = interface.launch(server_name="0.0.0.0", server_port=None, share=True)

    # Obtener la URL generada
    url = launch_result if isinstance(launch_result, str) else launch_result[1] if isinstance(launch_result, tuple) else None

    if url:
        print(f"Abriendo en el navegador: {url}")
        webbrowser.open(url)
    else:
        print("No se pudo obtener la URL de Gradio.")

# Función para iniciar Gradio en un hilo separado
def iniciar_gradio():
    threading.Thread(target=ejecutar_gradio, daemon=True).start()

# Crear la ventana de la interfaz
ventana = ctk.CTk()
ventana.title("Lanzador de Clasificador de Desenfoque")
ventana.geometry("500x300")

# Etiqueta explicativa
etiqueta = ctk.CTkLabel(
    ventana,
    text="Esta aplicación permite clasificar el desenfoque en imágenes.\nPresiona el botón para iniciar la interfaz de Gradio.",
    font=("Arial", 14),
    wraplength=450
)
etiqueta.pack(pady=20)

# Botón para ejecutar el servidor
boton_iniciar = ctk.CTkButton(
    ventana,
    text="Iniciar Clasificador",
    command=iniciar_gradio
)
boton_iniciar.pack(pady=20)

# Ejecutar la ventana
ventana.mainloop()

