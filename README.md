# Swift Zephyr RFID Example

This is a simple example project that shows off how Swift can interop with Zephyr using CMake. This example shows off integration with the following features:

- GPIO LED / Output
- Bluetooth (Advertising)
- SPI

> [!NOTE]
> Much of the code in this example is based off the work of [Eric Bariaux](https://www.ericbariaux.com/). He was kind enough to share his Swift -> Zephyr examples for the nRF52, which helped significantly with getting started and building this example as well. Check out the [nelcea](https://github.com/nelcea) repo on GitHub for more awesome examples from Eric!

This example is coded to work with the [Adafruit Feather nRF52840 Express](https://docs.zephyrproject.org/latest/boards/adafruit/feather_nrf52840/doc/index.html), but can also work with other BLE-enabled boards with an additional overlay file in the boards/ directory.

Other required/recommended hardware:

- MFRC522 Card Reader ([available on Amazon](https://www.amazon.com/mfrc522/s?k=mfrc522))
- Beeper / Buzzer ([like these ones for Arduino](https://www.amazon.com/Cylewet-Electronic-Magnetic-Continuous-Arduino/dp/B01N7NHSY6/ref=sr_1_3?crid=1S4NKFVKHYDJR&dib=eyJ2IjoiMSJ9.-8FtNMfHU_VTc9hGqdmX2KVN9UWUcC3HtnXNezyEx6SmfXSz7L8lO02t-zpWGerHkr9oIr6K2a2RKdLa4CKBFdvt327jBtZrtaGYikjXlSSIyl0MHkNJuStaDi0Hh8-uGbRYsi6VFnjWwXmAQAoFVnPVSsp589Zn7OfByAIp4aQG9yWXzZjy1QifxkrIQY5IW-BjNI2PTqHtJI5PPl_zlyFMroF4qdZQ7US7AoPgZ1g.3wjaIodJkb0SLtDW7zGm95aMLlp8qY3q4pqzQP2Zoak&dib_tag=se&keywords=buzzer+embedded&qid=1746564542&sprefix=buzzer+embedde%2Caps%2C122&sr=8-3))
- Breadboard (optional), these can be purchased from Amazon, Adafruit, Digikey, etc...

Something like this can be constructed:

![Sample Hardware Setup for the Swift Zephyr RFID Example](images/sample-setup.jpg "Sample Setup")

When the RFID tag is scanned, the BLE manufacturer data is set to the 5-bytes scanned from the (Mifare) tag. In the LightBlue app (recommended), the RFID tag appears like this in the scanning list:

![RFID in manufacturer data of SwiftRFID peripheral](images/swift-rfid-lightblue.jpg "SwiftRFID Advertising in LightBlue")
