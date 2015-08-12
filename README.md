The Imp's behavior when unable to connect to the Electric Imp cloud or when it becomes disconnected isn't entirely clear from the [documentation](https://electricimp.com/docs/api/server/).

The nuts here, for device and agent, just allowed me to test what the Imp did under various conditions.

The Imp should be wired up with two LEDs - connected to pins 1 and 2. These are used to signal what's happening (as the imp cannot use the usual `server.log()` if it's not connected to the cloud).

The findings generated by using this project and seeing how the Imp behaved if its AP was unavailable at startup etc. are noted at the end of the [device nut](device.nut).
