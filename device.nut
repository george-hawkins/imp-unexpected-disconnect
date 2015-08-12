// Adapted from the first example from https://electricimp.com/docs/api/server/onunexpecteddisconnect/

// Set the timeout policy to RETURN_ON_ERROR, ie. to continue running at disconnect
server.setsendtimeoutpolicy(RETURN_ON_ERROR, WAIT_TIL_SENT, 180);

// server.onunexpecteddisconnect() reports on pin1.
// Polling of server.isconnected() reports on pin2.

hardware.pin1.configure(DIGITAL_OUT);
hardware.pin1.write(1);
//hardware.pin1.write(server.isconnected() ? 1 : 0);
hardware.pin2.configure(DIGITAL_OUT);
hardware.pin2.write(server.isconnected() ? 1 : 0);

function disconnectHandler(reason) {
    if (reason != SERVER_CONNECTED) {
        // Server is not connected, so...
        hardware.pin1.write(0);
        
        // And attempt to reconnect.
        server.connect(disconnectHandler, 60);
    } else {
        // Server is connected, so...
        hardware.pin1.write(1);
    }
}

// Poll server.isconnected().
function pollIsConnected() {
	imp.wakeup(1.0, pollIsConnected);
	
//	agent.send("ping", null);
    hardware.pin2.write(server.isconnected() ? 1 : 0);
}

pollIsConnected();

server.onunexpecteddisconnect(disconnectHandler);

if (server.isconnected()) {
    server.log("boot ROM version: " + imp.getbootromversion());
    server.log("software version: " + imp.getsoftwareversion());
    server.log("environment: " + imp.environment());
}

// Findings apply to:
// * boot ROM version: d7fb311 - release-32.10 - Tue Jun 16 11:12:52 2015
// * software version: 78f540f - release-32.12 - Thu Jul 16 09:55:33 2015
//
// The timeout argument to server.setsendtimeoutpolicy() seems to be ignored, it
// has no affect on how quickly server.onunexpecteddisconnect() callbacks are
// invoked.
//
// If the AP is turned off the server.onunexpecteddisconnect() callbacks are
// invoked after about 60 to 75 seconds irrespective of whether the setsendtimeoutpolicy()
// is lower (e.g. 30) or higher (e.g. 180) than this.
//
// The documentation seems to suggest onunexpecteddisconnect() callbacks are
// triggered timeout amount of time after active communication, e.g. agent.send(),
// is attempted and the connection is not available.
//
// This is not the case onunexpecteddisconnect() callbacks are invoked 60 to 75
// seconds after the connection is lost even if no communication whatsoever was
// attempted.
//
// Polling server.isconnected() is a quicker way to detect disconnection but even
// it will continue to report true for around 10 seconds after the connection is
// lost.
//
// If you turn the AP off and back on within the 60 to 75 second window you will
// see server.isconnected() report false and then some time later report true. I.e.
// the connection is reestablished without any explicit handling and the
// onunexpecteddisconnect() callbacks are never called.
//
// Adding in active communication, e.g. sending a ping with agent.send(), doesn't
// cause either onunexpecteddisconnect() or isconnected() to behave any different,
// i.e. notice the loss of connection any quicker.
//
// If the AP is not available during device startup then isconnected() will report
// false right from the start as expected, less obviously onunexpecteddisconnect()
// is called, again the setsendtimeoutpolicy() timeout value seems irrelevant and
// this happens about 50 seconds after startup, i.e. slightly quicker than when
// the connection is lost while the device is already up and running.
//
// There seems to be nothing to be gained by setting the timeout for server.connect()
// low unless you want feedback quicker that a connection could not be reestablished.
//
// While the device is slow to notice the loss of a connection it seems very quick
// to reestablish one if server.connect() has been called (and not timed out) and
// the AP becomes available again.
//
// If you want send() calls to be synchronous see the WAIT_TIL_SENT option for
// server.setsendtimeoutpolicy().