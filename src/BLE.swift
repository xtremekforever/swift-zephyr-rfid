typealias BLEConnected = @convention(c) (
    _ conn: UnsafeMutablePointer<bt_conn>?,
    _ err: UInt8
) -> Void

typealias BLEDisconnected = @convention(c) (
    _ conn: UnsafeMutablePointer<bt_conn>?,
    _ reason: UInt8
) -> Void

/// Represents the BLE stack
struct BLE {
    static func enable() {
        let err = bt_enable(nil)
        if err != 0 {
            fatalError("Bluetooth init failed (err \(err)")
        }
        print("Bluetooth initialized")
    }

    static var conn_callbacks = bt_conn_cb()
    static func registerCallbacks(connected: BLEConnected? = nil, disconnected: BLEDisconnected? = nil) {
        conn_callbacks.connected = connected
        conn_callbacks.disconnected = disconnected

        bt_conn_cb_register(&conn_callbacks)
    }
}

struct BTData {
    let type: UInt8
    var bytes: [UInt8]
}

enum BTDataTypes {
    case flags(UInt8)
    case nameComplete(String)
    case manufacturerData([UInt8])

    var btData: BTData {
        switch self {
        case .flags(let flag):
            return BTData(type: UInt8(BT_DATA_FLAGS), bytes: [flag])
        case .nameComplete(let name):
            return BTData(type: UInt8(BT_DATA_NAME_COMPLETE), bytes: Array(name.utf8))
        case .manufacturerData(let bytes):
            return BTData(type: UInt8(BT_DATA_MANUFACTURER_DATA), bytes: bytes)
        }
    }
}

enum BLEFlags {
    static let generalDiscoverable = UInt8(BT_LE_AD_GENERAL)
    static let noBREDR = UInt8(BT_LE_AD_NO_BREDR)
}

struct ManufacturerData {
    let companyCode: UInt16
    var data: [UInt8]
}

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
    private var parameters: bt_le_adv_param
    private var adsd: AdvertisementAndScanResponse

    init(parameters: bt_le_adv_param, advertisementData: [BTDataTypes], scanResponseData: [BTDataTypes]) {
        self.parameters = parameters
        self.adsd = AdvertisementAndScanResponse(
            advertisementData: advertisementData.map { $0.btData },
            scanResponseData: scanResponseData.map { $0.btData }
        )
    }

    mutating func start() {
        bt_le_adv_start(&parameters, adsd.ad, adsd.adCount, adsd.sd, adsd.sdCount)
    }

    mutating func update(advertisementData: [BTDataTypes], scanResponseData: [BTDataTypes]) {
        self.adsd = AdvertisementAndScanResponse(
            advertisementData: advertisementData.map { $0.btData },
            scanResponseData: scanResponseData.map { $0.btData }
        )

        bt_le_adv_update_data(adsd.ad, adsd.adCount, adsd.sd, adsd.sdCount)
    }
}

// MARK: Extensions
extension bt_le_adv_param {
    init(options: UInt32, minInterval: UInt32, maxInterval: UInt32) {
        self.init(
            id: UInt8(BT_ID_DEFAULT),
            sid: 0,
            secondary_max_skip: 0,
            options: options,
            interval_min: minInterval,
            interval_max: maxInterval,
            peer: nil
        )
    }
}

extension bt_le_adv_param {
    /// Equivalent of the BT_LE_ADV_NCONN C macro, defining a non-connectable advertising with private address.
    static func bt_le_adv_nconn() -> bt_le_adv_param {
        return bt_le_adv_param(
            options: 0, minInterval: UInt32(BT_GAP_ADV_FAST_INT_MIN_2),
            maxInterval: UInt32(BT_GAP_ADV_FAST_INT_MAX_2)
        )
    }

    static func bt_le_adv_conn() -> bt_le_adv_param {
        return bt_le_adv_param(
            options: 1,
            minInterval: UInt32(BT_GAP_ADV_FAST_INT_MIN_2),
            maxInterval: UInt32(BT_GAP_ADV_FAST_INT_MAX_2)
        )
    }

    static func bt_le_adv_conn3() -> bt_le_adv_param {
        return bt_le_adv_param(
            options: 5, minInterval: 800, maxInterval: 801
        )
    }
}
