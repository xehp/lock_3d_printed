

Put "habl" on the atmega168
http://www.eit.se/habl/


# Install compiler and avrdude (on debian/ubuntu/mint style linux):
sudo apt-get install gcc-avr avr-libc binutils-avr avrdude

apt-get install picocom cutecom lrzsz screen

http://unix.stackexchange.com/questions/56614/send-file-by-xmodem-or-kermit-protocol-with-gnu-screen

make sure to allow user to use dialout (or else you must run screen and cutecom as root) replace henrik below with your username.
sudo usermod -a -G dialout henrik


Connect to the device
screen /dev/ttyUSB0 19200
To leave Ctrl-A D
To and kill screen: Ctrl-A k y


If you used "Ctrl-A D" Then kill screen before opening cutecom (replace 3622 with actual pid):
screen -r 3622 -X kill

Send the file havrapp.bin with cutecom xmodem












