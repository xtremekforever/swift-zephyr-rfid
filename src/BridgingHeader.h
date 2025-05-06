#include <autoconf.h>
#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>

#include <zephyr/bluetooth/bluetooth.h>
#include <zephyr/bluetooth/gatt.h>
#include <zephyr/bluetooth/hci.h>

// See [struct bt_conn issue, how to include conn_internal.h - Nordic Q&A - Nordic DevZone - Nordic DevZone](https://devzone.nordicsemi.com/f/nordic-q-a/88467/struct-bt_conn-issue-how-to-include-conn_internal-h)
#include <../subsys/bluetooth/host/conn_internal.h>

#define LED0_NODE DT_ALIAS(led0)
static struct gpio_dt_spec led0 = GPIO_DT_SPEC_GET(LED0_NODE, gpios);

#define BUZZER_NODE DT_ALIAS(buzzer)
static struct gpio_dt_spec buzzer = GPIO_DT_SPEC_GET(BUZZER_NODE, gpios);
