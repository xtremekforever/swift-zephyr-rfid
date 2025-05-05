@main
struct Main {
    static func main() {
        let led0Handle = Led(gpio: &led0)

        while true {
            led0Handle.toggle()

            k_msleep(100)
        }
    }
}
