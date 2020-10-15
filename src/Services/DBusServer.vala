[DBus (name = "com.github.stsdc.monitor")]
public class Monitor.DBusServer : Object {
    private const string DBUS_NAME = "com.github.stsdc.monitor";
    private const string DBUS_PATH = "/com/github/stsdc/monitor";

    private static GLib.Once<DBusServer> instance;

    public static unowned DBusServer get_default () {
        return instance.once (() => { return new DBusServer (); });
    }

    public signal void update (ResourcesSerialized data);
    public signal void indicator_state (bool state);
    public signal void quit ();
    public signal void show ();

    construct {
        Bus.own_name (
            BusType.SESSION,
            DBUS_NAME,
            BusNameOwnerFlags.NONE,
            (connection) => on_bus_aquired (connection),
            () => { },
            null
            );
    }

    public void quit_monitor () throws IOError, DBusError {
        quit ();
    }

    public void show_monitor () throws IOError, DBusError {
        show ();
    }

    private void on_bus_aquired (DBusConnection conn) {
        try {
            debug ("DBus registered!");
            conn.register_object ("/com/github/stsdc/monitor", get_default ());
        } catch (Error e) {
            error (e.message);
        }
    }
}

[DBus (name = "com.github.stsdc.monitor")]
public errordomain DBusServerError {
    SOME_ERROR
}
