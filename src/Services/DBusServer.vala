namespace Monitor {

    [DBus (name = "com.github.stsdc.monitor")]
    public class DBusServer : Object {
        private static GLib.Once<DBusServer> instance;
        public static unowned DBusServer get_default () {
            return instance.once (() => { return new DBusServer (); });
        }

        private int counter;

        public signal void pong (int count, string msg);
        public signal void update (Utils.SystemResources data);
        public signal void indicator_state (bool state);
        public signal void quit ();

        construct {
            Bus.own_name (
                BusType.SESSION,
                "com.github.stsdc.monitor",
                BusNameOwnerFlags.NONE,
                (conn) => on_bus_aquired (conn),
                (c, name) => info ("%s name aquired successfully!", name),
                () => warning ("Could not aquire name\n")
            );
        }

        public int ping (string msg) {
            stdout.printf ("%s\n", msg);
            return counter++;
        }

        public void quit_monitor () {
            quit ();
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

        private void on_bus_aquired (DBusConnection conn) {
            try {
                conn.register_object ("/com/github/stsdc/monitor", this);
            } catch (IOError e) {
                error ("Could not register service\n");
            }
        }
    }

    [DBus (name = "com.github.stsdc.monitor")]
    public errordomain DemoError
    {
        SOME_ERROR
    }
}
