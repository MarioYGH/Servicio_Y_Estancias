#include <string.h>
#include <sys/unistd.h>
#include <sys/stat.h>
#include "esp_adc/adc_oneshot.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_sleep.h"
#include "driver/i2c.h"
#include <stdio.h>
#include <stdlib.h>
#include "driver/uart.h"

#define ADC1_CHAN7 ADC_CHANNEL_7 /* GPIO 35 for Sensor 1 */
#define ADC1_CHAN4 ADC_CHANNEL_4 /* GPIO 32 for Sensor 2 */
#define ADC1_CHAN5 ADC_CHANNEL_5 /* GPIO 33 for Sensor 3 */
#define ADC_ATTEN ADC_ATTEN_DB_11
#define N_SENSORS 3

#define GPIO_SENSOR1_STATE GPIO_NUM_25 /* GPIO pin for Sensor 1 state */
#define GPIO_SENSOR2_STATE GPIO_NUM_26 /* GPIO pin for Sensor 2 state */
#define GPIO_SENSOR3_STATE GPIO_NUM_27 /* GPIO pin for Sensor 3 state */

// Definición de etiquetas y pines I2C
#define I2C_MASTER_SCL_IO           22      // Pin para SCL
#define I2C_MASTER_SDA_IO           21      // Pin para SDA
#define I2C_MASTER_FREQ_HZ          100000  // Frecuencia del bus I2C
#define I2C_MASTER_PORT             I2C_NUM_0
#define DS1307_ADDR                 0x68    // Dirección del RTC DS1307

#define PIN_TXD_UART_1 1
#define PIN_RXD_UART_1 3
#define PIN_TXD_UART_2 17 /* Connect to RX pin in LoRa board */
#define PIN_RXD_UART_2 16 /* Connect to TX pin in LoRa board */
#define PIN_RTS UART_PIN_NO_CHANGE
#define PIN_CTS UART_PIN_NO_CHANGE

#define UART_1_PORT UART_NUM_1
#define UART_2_PORT UART_NUM_2
#define UART_BAUD_RATE  115200
#define UART_BAUD_RATE_LORA 9600
#define ECHO_TASK_STACK_SIZE 2048

#define BUF_SIZE 1024

static const char *TAG = "System v0.1";

adc_oneshot_unit_handle_t adc1_handle;
static int adc_raws[N_SENSORS] = {0, 0, 0};
static float adc_voltages[N_SENSORS] = {0.0, 0.0, 0.0};
static float distances[N_SENSORS] = {0.0, 0.0, 0.0};
static bool sensor_states[N_SENSORS] = {true, true, true}; // States for each sensor

// Coefficients for the distance conversion polynomials
static const float coefficients[N_SENSORS][6] = {
    {0.43845, -3.1136, 6.6372, -5.4496, 35.144, 0.53767}, // Sensor 1
    {0.43845, -3.1136, 6.6372, -5.4496, 35.144, 0.53767}, // Sensor 2
    {0.43845, -3.1136, 6.6372, -5.4496, 35.144, 0.53767}  // Sensor 3
};

//Uart LoRa
esp_err_t uart1_initialization(){
    uart_config_t uart_config = {
        .baud_rate = UART_BAUD_RATE,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };

    int intr_alloc_flags = 0;
    #if CONFIG_UART_ISR_IN_IRAM
        intr_alloc_flags = ESP_INTR_FLAG_IRAM;
    #endif

    ESP_ERROR_CHECK(uart_driver_install(UART_1_PORT, BUF_SIZE * 2, 0, 0, NULL, intr_alloc_flags));
    ESP_ERROR_CHECK(uart_param_config(UART_1_PORT, &uart_config));
    ESP_ERROR_CHECK(uart_set_pin(UART_1_PORT, PIN_TXD_UART_1, PIN_RXD_UART_1, PIN_RTS, PIN_CTS));

    return ESP_OK;
}

esp_err_t uart2_initialization(){
    uart_config_t uart_config = {
        .baud_rate = UART_BAUD_RATE_LORA,
        .data_bits = UART_DATA_8_BITS,
        .parity    = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };

    int intr_alloc_flags = 0;
    #if CONFIG_UART_ISR_IN_IRAM
        intr_alloc_flags = ESP_INTR_FLAG_IRAM;
    #endif

    ESP_ERROR_CHECK(uart_driver_install(UART_2_PORT, BUF_SIZE * 2, 0, 0, NULL, intr_alloc_flags));
    ESP_ERROR_CHECK(uart_param_config(UART_2_PORT, &uart_config));
    ESP_ERROR_CHECK(uart_set_pin(UART_2_PORT, PIN_TXD_UART_2, PIN_RXD_UART_2, PIN_RTS, PIN_CTS));

    return ESP_OK;
}

// Función para inicializar el bus I2C
static esp_err_t i2c_master_init(void) {
    i2c_config_t conf = {
        .mode = I2C_MODE_MASTER,
        .sda_io_num = I2C_MASTER_SDA_IO,
        .sda_pullup_en = GPIO_PULLUP_ENABLE,
        .scl_io_num = I2C_MASTER_SCL_IO,
        .scl_pullup_en = GPIO_PULLUP_ENABLE,
        .master.clk_speed = I2C_MASTER_FREQ_HZ,
    };
    esp_err_t ret = i2c_param_config(I2C_MASTER_PORT, &conf);
    if (ret != ESP_OK) return ret;

    return i2c_driver_install(I2C_MASTER_PORT, conf.mode, 0, 0, 0);
}

// Función para convertir BCD a decimal
static uint8_t bcd_to_decimal(uint8_t val) {
    return ((val / 16 * 10) + (val % 16));
}

// Función para leer los datos del DS1307
static esp_err_t ds1307_read_time(void) {
    uint8_t buffer[7];
    uint8_t reg = 0x00;

    // Escribir dirección de registro inicial
    i2c_cmd_handle_t cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, (DS1307_ADDR << 1) | I2C_MASTER_WRITE, true);
    i2c_master_write_byte(cmd, reg, true);
    i2c_master_stop(cmd);
    esp_err_t ret = i2c_master_cmd_begin(I2C_MASTER_PORT, cmd, 1000 / portTICK_PERIOD_MS);
    i2c_cmd_link_delete(cmd);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Error al escribir en el RTC: %s", esp_err_to_name(ret));
        return ret;
    }

    // Leer datos del RTC
    cmd = i2c_cmd_link_create();
    i2c_master_start(cmd);
    i2c_master_write_byte(cmd, (DS1307_ADDR << 1) | I2C_MASTER_READ, true);
    i2c_master_read(cmd, buffer, sizeof(buffer) - 1, I2C_MASTER_ACK);
    i2c_master_read_byte(cmd, buffer + 6, I2C_MASTER_NACK);
    i2c_master_stop(cmd);
    ret = i2c_master_cmd_begin(I2C_MASTER_PORT, cmd, 1000 / portTICK_PERIOD_MS);
    i2c_cmd_link_delete(cmd);
    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Error al leer del RTC: %s", esp_err_to_name(ret));
        return ret;
    }

    // Convertir y mostrar la hora
    uint8_t seconds = bcd_to_decimal(buffer[0] & 0x7F);
    uint8_t minutes = bcd_to_decimal(buffer[1]);
    uint8_t hours = bcd_to_decimal(buffer[2] & 0x3F); // Formato 24 horas
    uint8_t day = bcd_to_decimal(buffer[3]);
    uint8_t date = bcd_to_decimal(buffer[4]);
    uint8_t month = bcd_to_decimal(buffer[5]);
    uint8_t year = bcd_to_decimal(buffer[6]);

    ESP_LOGI(TAG, "Hora actual: %02d:%02d:%02d, Fecha: %02d/%02d/20%02d",
             hours, minutes, seconds, date, month, year);
    return ESP_OK;
}

void gpio_initialize() {
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << GPIO_SENSOR1_STATE) | (1ULL << GPIO_SENSOR2_STATE) | (1ULL << GPIO_SENSOR3_STATE),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_ENABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&io_conf);
}

void update_sensor_states() {
    sensor_states[0] = gpio_get_level(GPIO_SENSOR1_STATE);
    sensor_states[1] = gpio_get_level(GPIO_SENSOR2_STATE);
    sensor_states[2] = gpio_get_level(GPIO_SENSOR3_STATE);
}

esp_err_t adc_initialize() {
    /* ADC1 Init */
    adc_oneshot_unit_init_cfg_t init_config = {
        .unit_id = ADC_UNIT_1,
    };

    adc_oneshot_new_unit(&init_config, &adc1_handle);

    /* ADC1 Config */
    adc_oneshot_chan_cfg_t config = {
        .bitwidth = ADC_BITWIDTH_DEFAULT,
        .atten = ADC_ATTEN,
    };

    adc_oneshot_config_channel(adc1_handle, ADC1_CHAN7, &config);
    adc_oneshot_config_channel(adc1_handle, ADC1_CHAN4, &config);
    adc_oneshot_config_channel(adc1_handle, ADC1_CHAN5, &config);

    return ESP_OK;
}

esp_err_t get_adc_value(adc_oneshot_unit_handle_t handle, adc_channel_t chan, int *out_raw) {
    return adc_oneshot_read(handle, chan, out_raw);
}

void calculate_distance(int sensor_index, float voltage) {
    const float *coeff = coefficients[sensor_index];
    distances[sensor_index] = coeff[0]*voltage*voltage*voltage*voltage*voltage +
                               coeff[1]*voltage*voltage*voltage*voltage +
                               coeff[2]*voltage*voltage*voltage +
                               coeff[3]*voltage*voltage +
                               coeff[4]*voltage +
                               coeff[5];
}

void read_sensor(int sensor_index, adc_channel_t channel) {
    get_adc_value(adc1_handle, channel, &adc_raws[sensor_index]);
    adc_voltages[sensor_index] = adc_raws[sensor_index] * 3.3 / 4095.0;
    calculate_distance(sensor_index, adc_voltages[sensor_index]);
    ESP_LOGI(TAG, "Sensor %d Distance: %.2f mm", sensor_index + 1, distances[sensor_index]);
}

static void lora_task(void *arg){
    uint8_t *data = (uint8_t *) malloc(BUF_SIZE);

    // Configuración inicial para los comandos AT
    uart_write_bytes(UART_2_PORT, "AT+OPMODE=1\r\n", strlen("AT+OPMODE=1\r\n"));  // Modo propietario
    vTaskDelay(1000 / portTICK_PERIOD_MS);  // Espera para asegurar que se aplica el comando

    uart_write_bytes(UART_2_PORT, "AT+ADDRESS=200\r\n", strlen("AT+ADDRESS=200\r\n"));  // Dirección del LoRa
    vTaskDelay(1000 / portTICK_PERIOD_MS);  // Espera para que se configure

    ESP_LOGI(TAG, "Sent 'HELLO' to LoRa module.");
    // Enviar "HELLO" al otro LoRa
    uart_write_bytes(UART_2_PORT, "AT+SEND=200,5,HELLO\r\n", strlen("AT+SEND=200,5,HELLO\r\n"));    

    ESP_LOGI(TAG, "Entering deep sleep for 5 minutes...");
        esp_deep_sleep(300000000); // 5 minutes in microseconds
        // For 12 hours, change to: esp_deep_sleep(43200000000);
}

void app_main(void) {
    ESP_ERROR_CHECK(uart1_initialization());
    ESP_ERROR_CHECK(uart2_initialization());
    ESP_ERROR_CHECK(i2c_master_init()); // Inicialización del I2C para el RTC
    adc_initialize(); /* ADC initialization */
    gpio_initialize(); /* GPIO initialization */
    vTaskDelay(pdMS_TO_TICKS(500));

    while(1) {
        update_sensor_states(); /* Update sensor states from GPIO */

        if (sensor_states[0]) {
            read_sensor(0, ADC1_CHAN7);
        } else {
            ESP_LOGI(TAG, "Sensor 1 is disabled");
        }

        if (sensor_states[1]) {
            read_sensor(1, ADC1_CHAN4);
        } else {
            ESP_LOGI(TAG, "Sensor 2 is disabled");
        }

        if (sensor_states[2]) {
            read_sensor(2, ADC1_CHAN5);
        } else {
            ESP_LOGI(TAG, "Sensor 3 is disabled");
        }

        ds1307_read_time(); // Mostrar la hora del RTC
        vTaskDelay(pdMS_TO_TICKS(1000));

        xTaskCreate(lora_task, "lora_task", ECHO_TASK_STACK_SIZE, NULL, 10, NULL);

        vTaskDelay(pdMS_TO_TICKS(5000));
    }
}
