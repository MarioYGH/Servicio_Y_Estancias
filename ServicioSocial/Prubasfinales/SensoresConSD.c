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

#define EXAMPLE_MAX_CHAR_SIZE    64
#define MOUNT_POINT "/sdcard"
#define ADC1_CHAN7 ADC_CHANNEL_7 /* GPIO 35 for Sensor 1 */
#define ADC1_CHAN4 ADC_CHANNEL_4 /* GPIO 32 for Sensor 2 */
#define ADC1_CHAN5 ADC_CHANNEL_5 /* GPIO 33 for Sensor 3 */
#define ADC_ATTEN ADC_ATTEN_DB_11
#define N_SENSORS 3
#define BUF_SIZE 100

static const char *TAG = "System v0.1";

adc_oneshot_unit_handle_t adc1_handle;
static int adc_raws[N_SENSORS] = {0, 0, 0};
static float adc_voltages[N_SENSORS] = {0.0, 0.0, 0.0};

/* Pin assignments for SD SPI */ 
#define PIN_NUM_MISO  19 
#define PIN_NUM_MOSI  23 /* 10k pullup */ 
#define PIN_NUM_CLK   18
#define PIN_NUM_CS    5

static esp_err_t sd_write_data(const char *path, char *data){
    ESP_LOGI(TAG, "Opening file %s", path);
    FILE *f = fopen(path, "a");
    if (f == NULL) {
        ESP_LOGE(TAG, "Failed to open file for writing");
        return ESP_FAIL;
    }
    fprintf(f, data);
    fclose(f);
    ESP_LOGI(TAG, "File written");

    return ESP_OK;
}

esp_err_t adc_initialize(){
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

esp_err_t get_adc_value(adc_oneshot_unit_handle_t handle, adc_channel_t chan, int *out_raw){
    return adc_oneshot_read(handle, chan, out_raw);
}

void app_main(void){
    adc_initialize(); /* ADC initialization */

    char data[BUF_SIZE];

    esp_err_t ret;

    /* If format_if_mount_failed is set to true, SD card will be partitioned and
     * formatted in case when mounting fails. 
    */
    esp_vfs_fat_sdmmc_mount_config_t mount_config = {
        #ifdef CONFIG_EXAMPLE_FORMAT_IF_MOUNT_FAILED
                .format_if_mount_failed = true,
        #else
                .format_if_mount_failed = false,
        #endif // EXAMPLE_FORMAT_IF_MOUNT_FAILED
                .max_files = 5,
                .allocation_unit_size = 16 * 1024
    };

    sdmmc_card_t *card;
    const char mount_point[] = MOUNT_POINT;
    ESP_LOGI(TAG, "Initializing SD card");

    /*
     * Use settings defined above to initialize SD card and mount FAT filesystem.
     * Note: esp_vfs_fat_sdmmc/sdspi_mount is all-in-one convenience functions.
     * Please check its source code and implement error recovery when developing
     * production applications. 
    */
    ESP_LOGI(TAG, "Using SPI peripheral");

    /*
     * By default, SD card frequency is initialized to SDMMC_FREQ_DEFAULT (20MHz)
     * For setting a specific frequency, use host.max_freq_khz (range 400kHz - 20MHz for SDSPI)
    */
    sdmmc_host_t host = SDSPI_HOST_DEFAULT();

    spi_bus_config_t bus_cfg = {
        .mosi_io_num = PIN_NUM_MOSI,
        .miso_io_num = PIN_NUM_MISO,
        .sclk_io_num = PIN_NUM_CLK,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = 4000,
    };

    ret = spi_bus_initialize(host.slot, &bus_cfg, SDSPI_DEFAULT_DMA);

    if (ret != ESP_OK) {
        ESP_LOGE(TAG, "Failed to initialize bus.");
        return;
    }

    /*
     * This initializes the slot without card detect (CD) and write protect (WP) signals.
     * Modify slot_config.gpio_cd and slot_config.gpio_wp if your board has these signals.
    */
    sdspi_device_config_t slot_config = SDSPI_DEVICE_CONFIG_DEFAULT();
    slot_config.gpio_cs = PIN_NUM_CS;
    slot_config.host_id = host.slot;

    ESP_LOGI(TAG, "Mounting filesystem");
    ret = esp_vfs_fat_sdspi_mount(mount_point, &host, &slot_config, &mount_config, &card);

    if (ret != ESP_OK) {
        if (ret == ESP_FAIL) {
            ESP_LOGE(TAG, "Failed to mount filesystem. "
                     "If you want the card to be formatted, set the CONFIG_EXAMPLE_FORMAT_IF_MOUNT_FAILED menuconfig option.");
        } else {
            ESP_LOGE(TAG, "Failed to initialize the card (%s). "
                     "Make sure SD card lines have pull-up resistors in place.", esp_err_to_name(ret));
        }
        return;
    }

    ESP_LOGI(TAG, "Filesystem mounted");

    /* Card has been initialized, print its properties */
    sdmmc_card_print_info(stdout, card);

    /* First create a file. */
    const char *filep = MOUNT_POINT"/readings.dat";
    
    ret = sd_write_data(filep, "sensor_1_voltage,sensor_2_voltage,sensor_3_voltage\n");
    if (ret != ESP_OK) {
        return;
    }

    /* Format FATFS */
    #ifdef CONFIG_EXAMPLE_FORMAT_SD_CARD
        ret = esp_vfs_fat_sdcard_format(mount_point, card);
        if (ret != ESP_OK) {
            ESP_LOGE(TAG, "Failed to format FATFS (%s)", esp_err_to_name(ret));
            return;
        }
    #endif /* CONFIG_EXAMPLE_FORMAT_SD_CARD */

    while(1){
        get_adc_value(adc1_handle, ADC1_CHAN7, &adc_raws[0]);
        adc_voltages[0] = adc_raws[0] * 3.3 / 4095.0;
        ESP_LOGI(TAG, "Sensor 1 Voltage: %.2f V", adc_voltages[0]);

        get_adc_value(adc1_handle, ADC1_CHAN4, &adc_raws[1]);
        adc_voltages[1] = adc_raws[1] * 3.3 / 4095.0;
        ESP_LOGI(TAG, "Sensor 2 Voltage: %.2f V", adc_voltages[1]);

        get_adc_value(adc1_handle, ADC1_CHAN5, &adc_raws[2]);
        adc_voltages[2] = adc_raws[2] * 3.3 / 4095.0;
        ESP_LOGI(TAG, "Sensor 3 Voltage: %.2f V", adc_voltages[2]);

        strcpy(data, "");
        snprintf(data, sizeof(data), "%.2f,%.2f,%.2f\n", adc_voltages[0], adc_voltages[1], adc_voltages[2]);
        sd_write_data(filep, data);
        bzero(data, BUF_SIZE);

        vTaskDelay(pdMS_TO_TICKS(500));
    }

    /* All done, unmount partition and disable SPI peripheral 
    esp_vfs_fat_sdcard_unmount(mount_point, card);
    ESP_LOGI(TAG, "Card unmounted"); */

    /* deinitialize the bus after all devices are removed 
    spi_bus_free(host.slot);*/
}
