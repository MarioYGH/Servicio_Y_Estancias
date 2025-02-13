# Guardar el modelo entrenado
# model.save('blur_classification_model.h5')  # Archivo .h5
# model.save('blur_classification_model.keras')  # Archivo .h5

import tensorflow as tf

# Cargar el modelo entrenado
model = tf.keras.models.load_model('blur_classification_model.h5')

# Convertir a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Guardar el modelo convertido en un archivo .tflite
with open('blur_classification_model.tflite', 'wb') as f:
    f.write(tflite_model)
