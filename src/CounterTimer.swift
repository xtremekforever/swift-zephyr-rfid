struct CounterTimer {
    private let timeout: Int
    private var count = 0

    private let onTimeout: () -> Void

    init(timeout: Int, onTimeout: @escaping () -> Void) {
        self.timeout = timeout
        self.onTimeout = onTimeout
    }

    mutating func reset() {
        count = 0
    }

    mutating func updateCount() {
        if count >= timeout {
            onTimeout()
            count = 0
        } else {
            count += 1
        }
    }
}
