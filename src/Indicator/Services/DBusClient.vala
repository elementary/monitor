[DBus (name = "io.elementary.monitor")]
public interface Monitor.DBusClientInterface : Object {
    public abstract void quit_monitor () throws Error;
    public abstract void show_monitor () throws Error;
    public signal void update (ResourcesSerialized data);
    public signal void indicator_state (bool state);
    public signal void indicator_cpu_state (bool state);
    public signal void indicator_cpu_frequency_state (bool state);
    public signal void indicator_cpu_temperature_state (bool state);
    public signal void indicator_memory_state (bool state);
    public signal void indicator_network_up_state (bool state);
    public signal void indicator_network_down_state (bool state);
    public signal void indicator_gpu_state (bool state);
    public signal void indicator_gpu_memory_state (bool state);
    public signal void indicator_gpu_temperature_state (bool state);

}

public class Monitor.DBusClient : Object {
    public DBusClientInterface ? interface = null;

    private static GLib.Once<DBusClient> instance;
    public static unowned DBusClient get_default () {
        return instance.once (() => { return new DBusClient (); });
    }

    public signal void monitor_vanished ();
    public signal void monitor_appeared ();

    construct {
        try {
            interface = Bus.get_proxy_sync (
                BusType.SESSION,
                "io.elementary.monitor",
                "/com/github/stsdc/monitor"
                );

            Bus.watch_name (
                BusType.SESSION,
                "io.elementary.monitor",
                BusNameWatcherFlags.NONE,
                () => monitor_appeared (),
                () => monitor_vanished ()
                );
        } catch (IOError e) {
            error ("Monitor Indicator DBus: %s\n", e.message);
        }
    }
}
