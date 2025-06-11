@main
struct Main {
    static func createAdvertisementData(with manufacturerData: ManufacturerData) -> [BTDataTypes] {
        [
            BTDataTypes.flags(BLEFlags.generalDiscoverable | BLEFlags.noBREDR),
            BTDataTypes.nameComplete(CONFIG_BT_DEVICE_NAME),
            BTDataTypes.manufacturerData(manufacturerData.bytes),
        ]
    }

    static func main() {
        // Outputs
        let led0Handle = Led(gpio: &led0)
        let buzzerHandle = Led(gpio: &buzzer)

        // Card Reader
        let cardReader = MFRC522()

        // BLE
        BLE.enable()
        var manufacturerData = ManufacturerData(companyCode: 0x420, data: [])
        var advertisement = BLEAdvertisement(
            parameters: bt_le_adv_param.bt_le_adv_conn3(),
            advertisementData: createAdvertisementData(with: manufacturerData),
            scanResponseData: []
        )
        advertisement.start()

        // RFID tracking + BLE connection
        var currentRfid: MFRC522.SerialNumber? = nil
        var rfidValueTimer = CounterTimer(timeout: 400) {  // timeout after 60 seconds
            currentRfid = nil

            // Add RFID to manufacturing data, update ADV packet
            manufacturerData.data = []
            advertisement.update(
                advertisementData: createAdvertisementData(with: manufacturerData),
                scanResponseData: []
            )
        }

        while true {
            led0Handle.toggle()
            buzzerHandle.off()

            if currentRfid != nil {
                rfidValueTimer.updateCount()
            }

            // Read from the card reader, beep if it's a new code
            if let rfid = cardReader.serialNumber, rfid != currentRfid {
                // Add RFID to manufacturing data, update ADV packet
                manufacturerData.data = rfid.value
                advertisement.update(
                    advertisementData: createAdvertisementData(with: manufacturerData),
                    scanResponseData: []
                )

                buzzerHandle.on()
                currentRfid = rfid
            }

            k_msleep(150)
        }
    }
}

// NOTE: This currently fails to link if moved to a different file
extension ManufacturerData {
    var bytes: [UInt8] {
        return [UInt8(companyCode & 0xFF), UInt8(companyCode >> 8)] + data
    }
}
