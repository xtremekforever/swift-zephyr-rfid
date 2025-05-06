struct MFRC522 {
    struct SerialNumber: Equatable {
        static let size = 5

        let value: [UInt8]

        init(_ value: [UInt8]) {
            assert(value.count == Self.size)
            self.value = value
        }

        fileprivate static func createBuffer() -> [UInt8] {
            return .init(repeating: 0, count: size)
        }
    }

    init() {
        SPI_Init()
        TM_MFRC522_Init()
    }

    var serialNumber: SerialNumber? {
        var buffer = SerialNumber.createBuffer()
        if TM_MFRC522_Check(&buffer) == 0 {
            return SerialNumber(buffer)
        }
        return nil
    }
}
