[DBus (name = "com.github.stsdc.monitor")]
public interface Monitor.DBusClientInterface : Object {
    public abstract void quit_monitor () throws IOError;
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

        } catch (IOError e) {
            error ("%s\n", e.message);
        }
    }
}
