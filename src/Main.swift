@main
struct Main {
    static func main() {
        // Outputs
        let led0Handle = Led(gpio: &led0)
        let buzzerHandle = Led(gpio: &buzzer)

        // RFID tracking
        let cardReader = MFRC522()
        var currentRfid: MFRC522.SerialNumber? = nil
        var rfidValueTimer = CounterTimer(timeout: 6) {
            currentRfid = nil
        }

        while true {
            led0Handle.toggle()
            buzzerHandle.off()
            rfidValueTimer.updateCount()

            // Read from the card reader, beep if it's a new code
            if let rfid = cardReader.serialNumber, rfid != currentRfid {
                buzzerHandle.on()
                currentRfid = rfid
            }

            k_msleep(150)
        }
    }
}
