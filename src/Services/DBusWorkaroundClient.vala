[DBus (name = "com.github.stsdc.monitor.workaround.GetProcesses")]
public interface Monitor.DBusWorkaroundClientInterface : Object {
    public abstract HashTable<string, string>[] get_processes (string empty) throws Error;
    public abstract void end_process (int pid) throws Error;
    public abstract void kill_process (int pid) throws Error;

}

public class Monitor.DBusWorkaroundClient : Object {
    public DBusWorkaroundClientInterface ? interface = null;

    private static GLib.Once<DBusWorkaroundClient> instance;
    public static unowned DBusWorkaroundClient get_default () {
        return instance.once (() => { return new DBusWorkaroundClient (); });
    }

    construct {
        try {
            interface = Bus.get_proxy_sync (
                BusType.SESSION,
                "com.github.stsdc.monitor.workaround",
                "/com/github/stsdc/monitor/workaround"
                );

            Bus.watch_name (
                BusType.SESSION,
                "com.github.stsdc.monitor.workaround",
                BusNameWatcherFlags.NONE
                );
        } catch (IOError e) {
            error ("Monitor Indicator DBus: %s\n", e.message);
        }


    }
}
