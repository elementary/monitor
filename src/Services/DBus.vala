[DBus (name = "com.github.stsdc.monitor")]
public class DemoServer : Object {

    private int counter;

    public int ping (string msg) {
        stdout.printf ("%s\n", msg);
        return counter++;
    }

    public int ping_with_signal (string msg) {
        stdout.printf ("%s\n", msg);
        pong(counter, msg);
        return counter++;
    }

    /* Including any parameter of type GLib.BusName won't be added to the
       interface and will return the dbus sender name (who is calling the method) */
    public int ping_with_sender (string msg, GLib.BusName sender) {
        stdout.printf ("%s, from: %s\n", msg, sender);
        return counter++;
    }

    public void ping_error () throws Error {
        throw new DemoError.SOME_ERROR ("There was an error!");
    }

    public signal void pong (int count, string msg);
}

[DBus (name = "com.github.stsdc.monitor")]
public errordomain DemoError
{
    SOME_ERROR
}
