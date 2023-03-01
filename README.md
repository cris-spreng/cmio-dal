# CoreMediaIO Device Abstraction Layer (DAL)

Excercise implementation of a CoreMediaIO DAL plugin for creating a virtual webcam on macOS.

The plugin serves frames as a virtual webcam to host software (QuickTime, OBS, Chrome, etc)

# IMPORTANT

Apple dropped support for CMIO DAL plugins, they will only run on macOS <= 13 so unless you are running an oldie like me (Catalina 🤘) there's no point on playing with these tools naymore.


## Running

Build in Xcode
Right click `CMIOMinimalSample.plugin` in Xcode's 'Products' folder and choose 'Show in Finder'
Copy the plugin bundle to `/Library/CoreMediaIO/Plug-Ins/DAL/`
Open QuickTime
Watch the logs in Console.app for any logs prefixed with `CMIOMS`

You may also need to change the codesigning to use your own personal developer identity.



## Credits

This is just an excercise for invetigative purposes, not intended to become a real application. Heavily based on the work from https://github.com/johnboiles/coremediaio-dal-minimal-example

### Also Check
https://developer.apple.com/library/archive/samplecode/CoreMediaIO/Introduction/Intro.html
https://github.com/lvsti/CoreMediaIO-DAL-Example
