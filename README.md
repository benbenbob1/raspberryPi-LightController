raspberryPi-LightController
===========================

iOS app for connecting to a socket server run on a Raspberry Pi that controls the color and brightness of the LED light strips in my room.
The app also includes the option to use Bluetooth LE to allow the Pi to become an iBeacon - assuming a Bluetooth card capable of LE technology is present on both devices. To set up the beacon, run the following code on the Pi which utilizes hciutil:

    sudo hcitool -i hci0 cmd 0x08 0x0008 1E 02 01 1A 1A FF 4C 00 02 15 [28 digit UUID of bluetooth device on the pi] 00 00 00 00 C1 00
    sudo hciconfig hci0 leadv

To disable the beacon, run the following command:

    sudo hciconfig hci0 noleadv

Upon the iOS device locating the Pi, the lights will change from red to yellow to green depending on the distance between devices. Note: If the app is running in the background, it may take some time for this to happen.

The Pi controls the lights using a custom made circuit and pi-blaster [https://github.com/sarfata/pi-blaster]. The possible messages sent to the server from the app are as follows:

	• c r g b - set the color to r, g, b. The RGB values are integers ranging from 0 to 100
	• f s/e - start/end a fade loop. This fades through the colors of the rainbow in a separate loop
    • h s/e - start/end Christmas loop. This loop alternates between red and green every 3.8 seconds
    • p r/g/b PIN - changes the GPIO pin for the given color to the supplied pin. The default pins are:
		Red   - 23
		Green - 18
		Blue  - 24
