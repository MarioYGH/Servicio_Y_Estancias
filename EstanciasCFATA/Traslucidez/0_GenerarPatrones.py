import cv2
import numpy as np
import matplotlib.pyplot as plt
import os

# Función para generar una imagen con un patrón
def generate_pattern_image(pattern_size=(400, 400), pattern_type="lines"):
    """
    Genera una imagen con un fondo blanco y un patrón negro.
    :param pattern_size: Tamaño del patrón
    :param pattern_type: Tipo de patrón a usar ('lines', 'circles', 'squares')
    :return: Imagen con patrón
    """
    # Crear una imagen con fondo blanco
    image = np.ones((600, 600, 3), dtype=np.uint8) * 255  # Fondo blanco más grande

    # Generar el patrón según el tipo
    pattern = np.ones((pattern_size[0], pattern_size[1], 3), dtype=np.uint8) * 255  # Fondo blanco para el patrón
    if pattern_type == "lines":
        num_lines = 15
        for i in range(num_lines):
            color = (0, 0, 0)  # Color negro
            thickness = 3  # Grosor de las líneas
            # Dibujar líneas horizontales
            cv2.line(pattern, (0, i * (pattern_size[0] // num_lines)),
                     (pattern_size[1], i * (pattern_size[0] // num_lines)), color, thickness)
    elif pattern_type == "circles":
        num_circles = 7
        for i in range(num_circles):
            color = (0, 0, 0)  # Color negro
            radius = (i + 1) * 30  # Incremento en el radio
            center = (pattern_size[1] // 2, pattern_size[0] // 2)  # Centro de la imagen
            cv2.circle(pattern, center, radius, color, 4)  # Dibujar círculo
    elif pattern_type == "squares":
        num_squares = 8
        for i in range(num_squares):
            color = (0, 0, 0)  # Color negro
            thickness = 3  # Grosor del cuadrado
            start_point = (i * 40, i * 40)  # Esquinas de los cuadrados
            end_point = (start_point[0] + 60, start_point[1] + 60)
            cv2.rectangle(pattern, start_point, end_point, color, thickness)

    # Colocar el patrón en el centro de la imagen
    start_y = (image.shape[0] - pattern.shape[0]) // 2
    start_x = (image.shape[1] - pattern.shape[1]) // 2
    image[start_y:start_y + pattern.shape[0], start_x:start_x + pattern.shape[1]] = pattern

    return image

# Función para aplicar desenfoque progresivo
def apply_blur_effect(image, blur_level):
    """
    Aplica un efecto de desenfoque a la imagen.
    :param image: Imagen de entrada (numpy array)
    :param blur_level: Nivel de desenfoque (kernel size, debe ser impar y mayor a 1)
    :return: Imagen desenfocada
    """
    if blur_level < 1:
        return image  # Sin desenfoque
    kernel_size = max(1, 2 * blur_level + 1)  # Kernel size debe ser impar
    blurred_image = cv2.GaussianBlur(image, (kernel_size, kernel_size), 0)
    return blurred_image

# Niveles de desenfoque deseados (más de 10 imágenes)
blur_levels = np.linspace(0, 10, 21, dtype=int)  # Generar niveles de 0 a 10 con 21 puntos

# Patrones a usar
patterns = ["lines", "circles", "squares"]

# Crear carpeta de salida para guardar imágenes
output_folder = "./generated_images"
os.makedirs(output_folder, exist_ok=True)

# Generar imágenes con los diferentes niveles de desenfoque y patrones
generated_images = []
for blur_level in blur_levels:
    for pattern_type in patterns:
        img = generate_pattern_image(pattern_type=pattern_type)
        blurred_img = apply_blur_effect(img, blur_level)
        generated_images.append((blur_level, pattern_type, blurred_img))

# Generar y guardar las imágenes
for pattern_type in patterns:
    for blur_level in blur_levels:
        img = generate_pattern_image(pattern_type=pattern_type)
        blurred_img = apply_blur_effect(img, blur_level)

        # Crear nombre de archivo
        filename = f"{pattern_type}_blur_{blur_level}.png"
        file_path = os.path.join(output_folder, filename)

        # Guardar imagen
        cv2.imwrite(file_path, blurred_img)
        print(f"Imagen guardada: {file_path}")

print("Todas las imágenes han sido generadas y guardadas.")

# Visualizar las imágenes generadas
cols = 5  # Número de columnas en la visualización
rows = int(np.ceil(len(generated_images) / cols))
fig, axes = plt.subplots(rows, cols, figsize=(20, 15))  # Aumentar tamaño de la figura

for idx, (blur_level, pattern_type, img) in enumerate(generated_images):
    row, col = divmod(idx, cols)
    ax = axes[row, col]
    ax.imshow(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    ax.axis('off')
    ax.set_title(f"Blur {blur_level}\n{pattern_type}")

# Ajustar el diseño del gráfico
plt.tight_layout()
plt.show()
