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

// TODO: Why do ~Copyable types fail to link when in a different file?
struct AdvertisementAndScanResponse: ~Copyable {
    private var advertisementData: [BTData]
    private var scanResponseData: [BTData]
    private(set) var ad: UnsafeMutablePointer<bt_data>
    private(set) var sd: UnsafeMutablePointer<bt_data>

    var adCount: Int {
        advertisementData.count
    }

    var sdCount: Int {
        scanResponseData.count
    }

    init(advertisementData: [BTData], scanResponseData: [BTData]) {
        self.advertisementData = advertisementData
        self.scanResponseData = scanResponseData
        self.ad = Self.btDataBytes(btData: advertisementData)
        self.sd = Self.btDataBytes(btData: scanResponseData)
    }

    private static func btDataBytes(btData: [BTData]) -> UnsafeMutablePointer<bt_data> {
        let ret = UnsafeMutablePointer<bt_data>.allocate(capacity: btData.count)
        for (index, value) in btData.enumerated() {
            var value = value
            ret[index].type = value.type
            ret[index].data_len = UInt8(value.bytes.count)
            let data = UnsafeMutablePointer<UInt8>.allocate(capacity: value.bytes.count)
            data.initialize(from: &value.bytes, count: value.bytes.count)
            ret[index].data = UnsafePointer(data)
        }
        return ret
    }

    func release(data: UnsafeMutablePointer<bt_data>, for btData: [BTData]) {
        for (index, _) in btData.enumerated() {
            data[index].data.deallocate()
        }
        data.deallocate()
    }

    deinit {
        release(data: self.ad, for: self.advertisementData)
        release(data: self.sd, for: self.scanResponseData)
    }

}

struct BLEAdvertisement: ~Copyable {
    private var parameters: UnsafeMutablePointer<bt_le_adv_param>
    private var adsd: AdvertisementAndScanResponse

    init(parameters: bt_le_adv_param, advertisementData: [BTDataTypes], scanResponseData: [BTDataTypes]) {
        var params = parameters
        self.parameters = UnsafeMutablePointer<bt_le_adv_param>.allocate(capacity: 1)
        self.parameters.initialize(from: &params, count: 1)

        self.adsd = AdvertisementAndScanResponse(
            advertisementData: advertisementData.map { $0.btData },
            scanResponseData: scanResponseData.map { $0.btData }
        )
    }

    func start() {
        bt_le_adv_start(self.parameters, adsd.ad, adsd.adCount, adsd.sd, adsd.sdCount)
    }

    mutating func update(advertisementData: [BTDataTypes], scanResponseData: [BTDataTypes]) {
        self.adsd = AdvertisementAndScanResponse(
            advertisementData: advertisementData.map { $0.btData },
            scanResponseData: scanResponseData.map { $0.btData }
        )

        bt_le_adv_update_data(adsd.ad, adsd.adCount, adsd.sd, adsd.sdCount)
    }

    deinit {
        self.parameters.deallocate()
    }
}

// TODO: This also fails to link, not sure what causes that?
struct ManufacturerData {
    let companyCode: UInt16
    var data: [UInt8]

    var bytes: [UInt8] {
        return [UInt8(companyCode & 0xFF), UInt8(companyCode >> 8)] + data
    }
}
