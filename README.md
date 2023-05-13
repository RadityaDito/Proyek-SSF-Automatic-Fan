# Proyek-SSF-Automatic-Fan

## Introduction to the problem and the solution

Keeping a room cool during the hot summer months can be a very tough challenge. It isn't rare to see people resorting to manually turning on their
fans or AC units which can be considered inefficient and tedious, especially if you've lost your remote. To address this issue, our group has decided to create
an automatic fan that can detect and adjust to the changes in temperature within a room as to obtain a better and more suited fan for the hot summer.

Within this project, we will design a system that utilizes a fan equipped with the Sensor DHt11 to automatically turn on the fan whenever the temperature
within the room exceeds a pre-determined threshold and will automatically turn off whenever the temperature within said room returns to a comfortable level.

## Hardware design and implementation details

Within this circuit, we're using an Arduino Uno as our main microcontroller to run our program
A DHT11 sensor is used to read the current room temperature and use that information as an input to whether or not turn the fan on.
Within this circuit, LCD MAX7219 will show the current detected temperature and humidity of the room where the DHT11 sensor is located in.
Both a servo and an LED will be a signal that the fan is spinning around when the required parameters are met to turn the fan on.

### Software implementation details

#### Test results and performance evaluation

##### Conclusion and future work
