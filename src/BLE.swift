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
