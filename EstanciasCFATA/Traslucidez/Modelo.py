import cv2
import numpy as np
import os
import gradio as gr
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
from tensorflow.keras.utils import to_categorical
from sklearn.model_selection import train_test_split
from tensorflow.keras.optimizers import Adam

# Función para cargar las imágenes y sus etiquetas
def load_images_and_labels(image_folder):
    images = []
    labels = []
    for filename in os.listdir(image_folder):
        if filename.endswith(".png"):
            # Cargar imagen
            img = cv2.imread(os.path.join(image_folder, filename))
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            img = cv2.resize(img, (64, 64))  # Redimensionar a 64x64
            images.append(img)

            # Extraer el nivel de desenfoque desde el nombre del archivo
            parts = filename.split("_")
            blur_level = int(parts[2].split(".")[0])
            labels.append(blur_level)

    # Convertir las listas a arrays numpy
    images = np.array(images)
    labels = np.array(labels)

    # Normalizar imágenes
    images = images / 255.0

    # Codificar las etiquetas (si es necesario)
    labels = to_categorical(labels, num_classes=11)  # 11 niveles de desenfoque

    return images, labels

# Cargar las imágenes y etiquetas
image_folder = './generated_images'
X, y = load_images_and_labels(image_folder)

# Dividir en conjunto de entrenamiento y prueba
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Crear la red neuronal convolucional (CNN)
model = Sequential([
    Conv2D(32, (3, 3), activation='relu', input_shape=(64, 64, 3)),
    MaxPooling2D(pool_size=(2, 2)),
    Conv2D(64, (3, 3), activation='relu'),
    MaxPooling2D(pool_size=(2, 2)),
    Flatten(),
    Dense(128, activation='relu'),
    Dense(11, activation='softmax')  # 11 clases para los niveles de desenfoque
])

# Compilar el modelo
model.compile(optimizer=Adam(), loss='categorical_crossentropy', metrics=['accuracy'])

# Entrenar el modelo
model.fit(X_train, y_train, epochs=50, batch_size=32, validation_data=(X_test, y_test))

# Función para predecir el nivel de desenfoque de una nueva imagen
def predict_blur_level(image):
    # Preprocesar la imagen
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = cv2.resize(image, (64, 64))
    image = image / 255.0  # Normalizar
    image = np.expand_dims(image, axis=0)  # Añadir una dimensión para el batch

    # Realizar la predicción
    prediction = model.predict(image)
    blur_level = np.argmax(prediction)

    return f"Nivel de desenfoque: {blur_level}"

# Crear la interfaz de Gradio
interface = gr.Interface(fn=predict_blur_level,
                         inputs=gr.Image(type="numpy"),
                         outputs="text",
                         live=True)

# Iniciar la interfaz
interface.launch()
model.save('blur_classification_model.keras')
