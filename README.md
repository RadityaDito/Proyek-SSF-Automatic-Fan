# Proyek-SSF-Automatic-Fan

## Introduction to the problem and the solution

Keeping a room cool during the hot summer months can be a very tough challenge. It isn't rare to see people resorting to manually turning on their
fans or AC units which can be considered inefficient and tedious, especially if you've lost your remote. To address this issue, our group has decided to create
an automatic fan that can detect and adjust to the changes in temperature within a room as to obtain a better and more suited fan for the hot summer.

Within this project, we will design a system that utilizes a fan equipped with the Sensor DHt11 to automatically turn on the fan whenever the temperature
within the room exceeds a pre-determined threshold and will automatically turn off whenever the temperature within said room returns to a comfortable level.

### Hardware design and implementation details

Within this circuit, we're using an Arduino Uno as our main microcontroller to run our program
A DHT11 sensor is used to read the current room temperature and use that information as an input to whether or not turn the fan on.
Within this circuit, LCD MAX7219 will show the current detected temperature and humidity of the room where the DHT11 sensor is located in.
Both a motor and an LED will be a signal that the fan is spinning around when the required parameters are met to turn the fan on.

### Software implementation details

Within this project, the software made to be able to properly run the Automatic Fan accordingly uses an the Assembly Language. There are a few functions within this project:

- SPI_MAX7219_init
  This function is used to initialize the MAX7219 display monitor
- MAX7219_disp_text
  This function is used to show the data that is given by the next function
- DHT11_sensor
  This function is used to obtain the data from the DHT11 sensor
- HC_SR04_sensor
  This function is used to initialize the HCSR04 sensor and obtain the data as well

The main function within this project is used to call the functions said above.

## Test results and performance evaluation

There are a few conditions that are used for testing our component:
- Temperature < 20 degrees Celsius & range >/< than 30 cm
- Temperature 20 < x < 30 degrees Celsius & range >/< than 30 cm
- Temperature > 30 degrees Celsius & range >/< than 30 cm

The results were as expected. The left LED turns on and the motor is turned off whenever the temperature hits underneath 20 degrees celsius and will stay on (LED) even if there is no person in range. The middle LED will turn on and the motor will also turn on whenever the temperature is between 20 and 30 degrees Celsius and the motor will turn off when there is no person detected within 30 cm of the HCSR04 sensor. The right LED will turn on whenever temperatures hit above 30 degrees celsius and will turn off whenever the HCSR04 does not detect a person within 30 cms of range.

# Conclusion and future work

This automatic fan that us, Group B8 have developed is suited for a wide-range of people since it tackles a very widespread problem of the effectiveness of conventional fans. The upside of using this automatic fan is mostly practicallity in the sense that a person does not have to stand up or even move for the fan to activate thanks to it's automation.

For future work, we will try to add manual buttons as well for convenience if whether a person wants to or not have the automatic mode on and to set the speeds of which the motor spins the fan blades at.
