struct Led {
    let gpio: UnsafePointer<gpio_dt_spec>

    init(gpio: UnsafePointer<gpio_dt_spec>) {
        self.gpio = gpio

        guard gpio_is_ready_dt(gpio) else { return }

        let ret = gpio_pin_configure_dt(gpio, GPIO_OUTPUT | GPIO_OUTPUT_INIT_LOW | GPIO_OUTPUT_INIT_LOGICAL)
        guard ret == 0 else { return }
    }

    func on() {
        gpio_pin_set_dt(gpio, 1)
    }

    func off() {
        gpio_pin_set_dt(gpio, 0)
    }

    func toggle() {
        gpio_pin_toggle_dt(gpio)
    }
}
