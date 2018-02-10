[DBus (name = "com.github.stsdc.monitor")]
public interface Monitor.DBusClientInterface : Object {
    public abstract int ping (string msg) throws IOError;
    public abstract int ping_with_sender (string msg) throws IOError;
    public abstract int ping_with_signal (string msg) throws IOError;
    public signal void pong (int count, string msg);
    public signal void update (Utils.SystemResources data);
    public signal void indicator_state (bool state);
}

public class Monitor.DBusClient : Object{
    public DBusClientInterface? interface = null;

    private static GLib.Once<DBusClient> instance;
    public static unowned DBusClient get_default () {
        return instance.once (() => { return new DBusClient (); });
    }

    construct {
        try {
            interface = Bus.get_proxy_sync (BusType.SESSION, "com.github.stsdc.monitor",
                                                        "/com/github/stsdc/monitor");

            /* Connecting to signal pong! */
            interface.pong.connect((c, m) => {
                stdout.printf ("Got pong %d for msg '%s'\n", c, m);
            });

            // interface.indicator_state.connect((state) => {
            //     indicator_state ()
            //     info ("%d, %d", data.cpu_percentage, data.memory_percentage);
            // });

            int reply = interface.ping ("Hello from Vala");
            stdout.printf ("%d\n", reply);

            reply = interface.ping_with_sender ("Hello from Vala with sender");
            stdout.printf ("%d\n", reply);

            reply = interface.ping_with_signal ("Hello from Vala with signal");
            stdout.printf ("%d\n", reply);

        } catch (IOError e) {
            stderr.printf ("%s\n", e.message);
        }
    }
}
