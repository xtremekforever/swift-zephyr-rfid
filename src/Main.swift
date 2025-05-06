extension [UInt8] {
    mutating func reset(to value: UInt8) {
        for index in 0..<count {
            self[index] = value
        }
    }
}

@main
struct Main {
    static func main() {
        // Outputs
        let led0Handle = Led(gpio: &led0)
        let buzzerHandle = Led(gpio: &buzzer)

        // RFID tracking
        var rfidValue: [UInt8] = .init(repeating: 0, count: 5)
        var rfidValueTimer = CounterTimer(timeout: 6) {
            rfidValue.reset(to: 0)
        }

        // RFID Reader
        SPI_Init()
        TM_MFRC522_Init()

        while true {
            led0Handle.toggle()
            buzzerHandle.off()
            rfidValueTimer.updateCount()

            // RFID tags are just 5 bytes
            var newRfidValue: [UInt8] = .init(repeating: 0, count: 5)
            if TM_MFRC522_Check(&newRfidValue) == 0 {
                if rfidValue != newRfidValue {
                    rfidValue = newRfidValue
                    buzzerHandle.on()
                }
            }

            k_msleep(150)
        }
    }
}
