raspberryPi-LightController
===========================

iOS app for connecting to a socket server run on a Raspberry Pi that controls the LED lights in my room.
The app also includes the option to use Bluetooth LE to allow the Pi to become an iBeacon - assuming a Bluetooth card capable of LE technology is present on both devices. To up an iBeacon, run the following optimized code on the Pi which utilizes hciutil:

    sudo hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 [28 digit UUID of bluetooth device on the pi] 00 00 00 00 C1 00
    sudo hciconfig hci0 leadv

  To disable the beacon, run the following command:
    sudo hciconfig hci0 noleadv

Upon the iOS device locating the beacon, the lights will change from red to yellow to green depending on the distance from the Pi. Note: If the app is running in the background, it may take some time for this to happen.
