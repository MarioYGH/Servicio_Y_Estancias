/*
 * Dr. J.E. Solis-Perez <jsolisp@unam.mx>
 * Created: May 23, 2024
 * Modified: June 23, 2024
 */

#include <string.h>
#include <sys/unistd.h>
#include <sys/stat.h>
#include "esp_vfs_fat.h"
#include "sdmmc_cmd.h"
#include "driver/sdmmc_types.h" /* This library is neccesary to deal with the SD card via SPI. Change line 181 at sdmmc_types.h from 20000 to 5000 */
#include "driver/gpio.h"
#include "esp_adc/adc_oneshot.h"
#include "driver/uart.h"

#include "adc_config.h"
#include "gpio_config.h"
#include "sd_config.h"

#define ADDRESS_MASTER 666
#define LoRa_PORT UART_NUM_2
#define LoRa_BAUD_RATE 9600
#define PIN_TXD_LoRa 17
#define PIN_RXD_LoRa 16
#define PIN_RTS UART_PIN_NO_CHANGE
#define PIN_CTS UART_PIN_NO_CHANGE

#define BUF_SIZE 1024
#define TASK_SIZE 2048
#define BUF_SIZE_STR 100
#define N_SENSORS 3

static QueueHandle_t uart_queue;
static const char *TAG = "System Sender v0.1";

static int adc_raws[N_SENSORS] = {1989, 2013, 2023};
float displacements[N_SENSORS] = {1.2, 3.4, 5.6};

esp_err_t uart_initialization() {
    /* 
     * Configure parameters of an UART driver,
     * communication pins and install the driver
    */
    uart_config_t uart_config = {
        .baud_rate = LoRa_BAUD_RATE,
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

    ESP_ERROR_CHECK(uart_param_config(LoRa_PORT, &uart_config));
    ESP_ERROR_CHECK(uart_set_pin(LoRa_PORT, PIN_TXD_LoRa, PIN_RXD_LoRa, PIN_RTS, PIN_CTS));
    //ESP_ERROR_CHECK(uart_driver_install(LoRa_PORT, BUF_SIZE * 2, 0, 0, NULL, intr_alloc_flags));
    ESP_ERROR_CHECK(uart_driver_install(LoRa_PORT, BUF_SIZE, BUF_SIZE, 5, &uart_queue, intr_alloc_flags));

    return ESP_OK;
}

esp_err_t get_adc_values() {
    if(gpio_get_level(BOOL_SENSOR_1)) {
        get_ADC_value(ADC1_CHAN7, &adc_raws[0]);
        ESP_LOGI(TAG, "Sensor 1: %i", adc_raws[0]);
    }

    if(gpio_get_level(BOOL_SENSOR_2)) {
        get_ADC_value(ADC1_CHAN4, &adc_raws[1]);
        ESP_LOGI(TAG, "Sensor 2: %i", adc_raws[1]);
    }

    if(gpio_get_level(BOOL_SENSOR_3)) {
        get_ADC_value(ADC1_CHAN5, &adc_raws[2]);
        ESP_LOGI(TAG, "Sensor 3: %i", adc_raws[2]);
    }
    vTaskDelay(pdMS_TO_TICKS(250));

    return ESP_OK;
}

float convert_voltage_to_distance(float voltage) {
    float p1 = 0.43845;
    float p2 = -3.1136;
    float p3 = 6.6372;
    float p4 = -5.4496;
    float p5 = 35.144;
    float p6 = 0.53767;

    return p1*voltage*voltage*voltage*voltage*voltage +
           p2*voltage*voltage*voltage*voltage +
           p3*voltage*voltage*voltage +
           p4*voltage*voltage +
           p5*voltage +
           p6;
}

esp_err_t get_displacements() {
    for (int i = 0; i < N_SENSORS; ++i) {
        float voltage = (adc_raws[i] * 3.3 / 4095.0);
        displacements[i] = convert_voltage_to_distance(voltage);
    }
    return ESP_OK;
}

esp_err_t write_displacements2sd() {
    char data[BUF_SIZE_STR];

    if(gpio_get_level(BOOL_SENSOR_1) || gpio_get_level(BOOL_SENSOR_2) || gpio_get_level(BOOL_SENSOR_3)) {
        strcpy(data, "");
        snprintf(data, sizeof(data), "%i,%i,%i\n", adc_raws[0], adc_raws[1], adc_raws[2]);
        write_data2sd(data);
        bzero(data, BUF_SIZE_STR);
    }

    return ESP_OK;
}

static void rx_task_LoRa(void *arg) {
    // Configure a temporary buffer for the incoming data
    uint8_t *data = (uint8_t *) malloc(BUF_SIZE);
    uart_event_t rx_event;

    while (true) {
        if(xQueueReceive(uart_queue, &rx_event, portMAX_DELAY)) {

            /* Clear space memory */
            bzero(data, BUF_SIZE);

            switch(rx_event.type) {
                case UART_DATA:
                   /* Read data from the UART */
                    uart_read_bytes(LoRa_PORT, data, rx_event.size, pdMS_TO_TICKS(100));
                    ESP_LOGI(TAG, "Data received: %s", data);
                    break;
                default:
                    break;
            }
        }
    }
}

static void delay_10_min() {
    for(uint16_t k = 0; k < 600; k++)
        vTaskDelay(pdMS_TO_TICKS(1000));
}

static void tx_task_LoRa(void *args) {
    esp_log_level_set(TAG, ESP_LOG_INFO);

    char Txdata[BUF_SIZE_STR];
    char tmp[BUF_SIZE_STR / 4];
    
    char AT_command[] = "AT+SEND=%d,%d,%s\r\n";

    while (true) {
        get_adc_values();
        get_displacements();
        write_displacements2sd();

        strcpy(Txdata, "");
        snprintf(tmp, BUF_SIZE_STR / 4, "%.4f/%.4f/%.4f", displacements[0], displacements[1], displacements[2]);
        snprintf(Txdata, BUF_SIZE_STR, AT_command, ADDRESS_MASTER, strlen(tmp), tmp);
        uart_write_bytes(LoRa_PORT, Txdata, strlen(Txdata));
        ESP_LOGI(TAG, "AT command send!");

        for(uint8_t k = 0; k < 20; k++)
            vTaskDelay(pdMS_TO_TICKS(1000));
    }
}

static void create_SystemTasks() {
    xTaskCreate(rx_task_LoRa, "rx_task_LoRa", TASK_SIZE, NULL, configMAX_PRIORITIES-2, NULL);
    xTaskCreate(tx_task_LoRa, "tx_task_LoRa", TASK_SIZE, NULL, configMAX_PRIORITIES-1, NULL);
}

void app_main(void) {
    ESP_ERROR_CHECK(adc_initialize()); /* ADC initialization */
    ESP_ERROR_CHECK(pin_initialize()); /* Pin initialization */
    ESP_ERROR_CHECK(sd_initialize());
    ESP_ERROR_CHECK(uart_initialization());

    create_SystemTasks();

    /* All done, unmount partition and disable SPI peripheral */
    esp_vfs_fat_sdcard_unmount(mount_point, card);
    ESP_LOGI(TAG, "Card unmounted");

    /* deinitialize the bus after all devices are removed */
    spi_bus_free(host.slot);
}
