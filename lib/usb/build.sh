#!/bin/sh

echo "	JAVAC"
javac LowLevelUSB.java -g -Xlint:unchecked
echo "	JAVAH"
javah -classpath . LowLevelUSB
echo "	CC"
gcc LowLevelUSB.c -o libLowLevelUSB.so -I/usr/include/libusb-1.0/ -I/usr/lib/jvm/java-6-openjdk/include/ -I/usr/lib/jvm/java-6-openjdk/include/linux/ -lusb-1.0 -fPIC -rdynamic -shared
