@main
struct Main {
    static func main() {
        let led0Handle = Led(gpio: &led0)
        let buzzerHandle = Led(gpio: &buzzer)

        while true {
            led0Handle.toggle()

            k_msleep(100)
        }
    }
}
