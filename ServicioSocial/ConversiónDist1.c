/*
Autor: Mario García
Programa ESP32 ADC Para distancia con potenciometro lineal
date created: 25/02/24
last modified: 25/02/24
*/

#include <stdio.h>
#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_adc/adc_oneshot.h" //Para hacer lecturas Oneshot o continuas
//#include "esp_adc/adc_cali.h"  //Solo poner si se va a calibrar el ADC

#define ADC1_CHAN0 ADC_CHANNEL_4 //7
#define ADC_ATTEN ADC_ATTEN_DB_11

adc_oneshot_unit_handle_t adc1_handle;

static int adc_raw; 
static float voltage;

esp_err_t config_ADC();
esp_err_t get_ADC_value();


void app_main(void)
{
    config_ADC(); 

    while (true) {
        get_ADC_value();

        vTaskDelay(250/ portTICK_PERIOD_MS);
    } 

}

esp_err_t config_ADC() {
    //ADC init
    adc_oneshot_unit_init_cfg_t init_config1 = {
        .unit_id = ADC_UNIT_1,
    };

    adc_oneshot_new_unit(&init_config1, &adc1_handle);

    //ADC config
    adc_oneshot_chan_cfg_t config = {
        .bitwidth = ADC_BITWIDTH_DEFAULT, //ancho de banda
        .atten = ADC_ATTEN, //Atenuacion
    };

    adc_oneshot_config_channel(adc1_handle, ADC1_CHAN0, &config);
    
    return ESP_OK; 
}

esp_err_t get_ADC_value(){

    adc_oneshot_read(adc1_handle, ADC1_CHAN0, &adc_raw);
    printf("Raw data: %d\n", adc_raw);

    //Recordar que el ADC es de 12bits (4096) 
    voltage = (adc_raw * 3.3 / 4095.0); //importante poner el cero, para forzar la interpretación de la división como una operación de punto flotante.
    printf("Voltage: %2.2f V\n", voltage);

    // Convertir el voltaje a distancia en centímetros
    float distance_mm = voltage * (100.0 / 3.3); 
    printf("Distance: %2.2f mm\n", distance_mm);

    return ESP_OK;

}
