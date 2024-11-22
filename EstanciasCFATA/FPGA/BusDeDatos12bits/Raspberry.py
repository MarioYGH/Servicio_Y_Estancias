import RPi.GPIO as GPIO
import time

# Configurar los pines GPIO
GPIO.setmode(GPIO.BCM)
data_pins = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]  # Pines GPIO para el bus de datos de 16 bits
control_pin = 18  # Pin GPIO para el pulso de control

# Configurar los pines como salidas
for pin in data_pins:
    GPIO.setup(pin, GPIO.OUT)

GPIO.setup(control_pin, GPIO.OUT)

def send_data(data):
    for i in range(16):
        GPIO.output(data_pins[i], (data >> i) & 1)
    # Generar un pulso de control
    GPIO.output(control_pin, 1)
    time.sleep(0.001)
    GPIO.output(control_pin, 0)

try:
    # Abrir la imagen en formato binario
    with open("image.bin", "rb") as f:
        byte = f.read(2)  # Leer 16 bits (2 bytes) a la vez
        while byte:
            data = int.from_bytes(byte, byteorder='big')
            send_data(data)
            byte = f.read(2)
finally:
    GPIO.cleanup()
