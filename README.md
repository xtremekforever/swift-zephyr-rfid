# Swift Zephyr RFID Example

This is a simple example project that shows off how Swift can interop with Zephyr using CMake. This example shows off integration with the following features:

- GPIO LED / Output
- Bluetooth (Advertising)
- SPI

> [!NOTE]
> Much of the code in this example is based off the work of [Eric Bariaux](https://www.ericbariaux.com/). He was kind enough to share his Swift -> Zephyr examples for the nRF52, which helped significantly with getting started and building this example as well. Check out the [nelcea](https://github.com/nelcea) repo on GitHub for more awesome examples from Eric!

## Hardware Requirements

This example is coded to work with the [Adafruit Feather nRF52840 Express](https://docs.zephyrproject.org/latest/boards/adafruit/feather_nrf52840/doc/index.html), but can also work with other BLE-enabled boards with an additional overlay file in the boards/ directory.

Other required/recommended hardware:

- MFRC522 Card Reader ([available on Amazon](https://www.amazon.com/mfrc522/s?k=mfrc522))
- Beeper / Buzzer ([like these ones for Arduino](https://www.amazon.com/Cylewet-Electronic-Magnetic-Continuous-Arduino/dp/B01N7NHSY6/ref=sr_1_3?crid=1S4NKFVKHYDJR&dib=eyJ2IjoiMSJ9.-8FtNMfHU_VTc9hGqdmX2KVN9UWUcC3HtnXNezyEx6SmfXSz7L8lO02t-zpWGerHkr9oIr6K2a2RKdLa4CKBFdvt327jBtZrtaGYikjXlSSIyl0MHkNJuStaDi0Hh8-uGbRYsi6VFnjWwXmAQAoFVnPVSsp589Zn7OfByAIp4aQG9yWXzZjy1QifxkrIQY5IW-BjNI2PTqHtJI5PPl_zlyFMroF4qdZQ7US7AoPgZ1g.3wjaIodJkb0SLtDW7zGm95aMLlp8qY3q4pqzQP2Zoak&dib_tag=se&keywords=buzzer+embedded&qid=1746564542&sprefix=buzzer+embedde%2Caps%2C122&sr=8-3))
- Breadboard (optional), these can be purchased from Amazon, Adafruit, Digikey, etc...

Something like this can be constructed:

![Sample Hardware Setup for the Swift Zephyr RFID Example](images/sample-setup.jpg "Sample Setup")

When the RFID tag is scanned, the BLE manufacturer data is set to the 5-bytes scanned from the (Mifare) tag. In the LightBlue app (recommended), the RFID tag appears like this in the scanning list:

![RFID in manufacturer data of SwiftRFID peripheral](images/swift-rfid-lightblue.jpg "SwiftRFID Advertising in LightBlue")

## Software Requirements

In order to build this example, you'll need to install the following components:

 - Swift 6.1 or later, using the [official instructions](https://www.swift.org/install/linux/).
 - Zephyr SDK using the [Getting Started Guide](https://docs.zephyrproject.org/latest/develop/getting_started/index.html)).
 - The SEGGER J-Link tools which are available [here](https://www.segger.com/downloads/jlink).
 - The `nrfutil` binary, which depends on the SEGGER J-Link tools and is available [here](https://www.nordicsemi.com/Products/Development-tools/nRF-Util/Download#infotabs).

### Building

Start by sourcing Zephyr to get into the venv:

```bash
$ source ~/zephyrproject/.venv/bin/activate
```

A handy build script has been provided that will compile the firmware for the `adafruit_feature_nrf52840` for you:

```bash
$ ./build.sh
Loading Zephyr default modules (Freestanding).
-- Application: ~/swift-zephyr-rfid
-- CMake version: 4.0.2
-- Found Python3: ~/zephyrproject/.venv/bin/python (found suitable version "3.12.3", minimum required is "3.10") found components: Interpreter
-- Cache files will be written to: /home/xtremek/.cache/zephyr
-- Zephyr version: 4.1.0 (~/zephyrproject/zephyr)
-- Found west (found suitable version "1.3.0", minimum required is "0.14.0")
-- Board: adafruit_feather_nrf52840, qualifiers: nrf52840
-- ZEPHYR_TOOLCHAIN_VARIANT not set, trying to locate Zephyr SDK
-- Found host-tools: zephyr 0.17.0 (/home/xtremek/zephyr-sdk-0.17.0)
-- Found toolchain: zephyr 0.17.0 (/home/xtremek/zephyr-sdk-0.17.0)
-- Found Dtc: /home/xtremek/zephyr-sdk-0.17.0/sysroots/x86_64-pokysdk-linux/usr/bin/dtc (found suitable version "1.6.0", minimum required is "1.4.6")
-- Found BOARD.dts: ~/zephyrproject/zephyr/boards/adafruit/feather_nrf52840/adafruit_feather_nrf52840.dts
-- Found devicetree overlay: ~/swift-zephyr-rfid/boards/adafruit_feather_nrf52840.overlay
-- Generated zephyr.dts: ~/swift-zephyr-rfid/build/zephyr/zephyr.dts
-- Generated pickled edt: ~/swift-zephyr-rfid/build/zephyr/edt.pickle
-- Generated devicetree_generated.h: ~/swift-zephyr-rfid/build/zephyr/include/generated/zephyr/devicetree_generated.h
-- Including generated dts.cmake file: ~/swift-zephyr-rfid/build/zephyr/dts.cmake
Parsing ~/zephyrproject/zephyr/Kconfig
Loaded configuration '~/zephyrproject/zephyr/boards/adafruit/feather_nrf52840/adafruit_feather_nrf52840_defconfig'
Merged configuration '~/swift-zephyr-rfid/prj.conf'
Configuration saved to '~/swift-zephyr-rfid/build/zephyr/.config'
Kconfig header saved to '~/swift-zephyr-rfid/build/zephyr/include/generated/zephyr/autoconf.h'
-- Found GnuLd: /home/xtremek/zephyr-sdk-0.17.0/arm-zephyr-eabi/arm-zephyr-eabi/bin/ld.bfd (found version "2.38")
-- The C compiler identification is GNU 12.2.0
-- The CXX compiler identification is GNU 12.2.0
-- The ASM compiler identification is GNU
-- Found assembler: /home/xtremek/zephyr-sdk-0.17.0/arm-zephyr-eabi/bin/arm-zephyr-eabi-gcc
-- Using ccache: /usr/bin/ccache
-- The Swift compiler identification is Apple 6.1
-- Configuring done (5.7s)
-- Generating done (0.1s)
-- Build files have been written to: ~/swift-zephyr-rfid/build
[1/216] Preparing syscall dependency handling

[3/216] Generating include/generated/zephyr/version.h
-- Zephyr version: 4.1.0 (~/zephyrproject/zephyr), build: v4.1.0
[216/216] Linking C executable zephyr/zephyr.elf
Memory region         Used Size  Region Size  %age Used
           FLASH:      129456 B         1 MB     12.35%
             RAM:       18880 B       256 KB      7.20%
        IDT_LIST:          0 GB        32 KB      0.00%
Generating files from ~/swift-zephyr-rfid/build/zephyr/zephyr.elf for board: adafruit_feather_nrf52840
```

Otherwise, you can just run cmake directly instead:

```bash
$ cmake -B build -G Ninja -DBOARD=adafruit_feather_nrf52840 -DUSE_CCACHE=0 .
$ cmake --build build
```

### Programming

Another handy-dandy script is provided to program the device, verify the firmware, and reset it using `nrfutil`:

```bash
$ ./program.sh
[00:00:02] ###### 100% [2/2 802001236] Programmed
✔️ Firmware was verified on 802001236
✔️ Reset was applied to 802001236
```

You can also run the commands manually if desired:

```bash
$ nrfutil device program --firmware build/zephyr/zephyr.hex
$ nrfutil device fw-verify --firmware build/zephyr/zephyr.hex
$ nrfutil device reset
```
