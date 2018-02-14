namespace Monitor {

    [DBus (name = "com.github.stsdc.monitor")]
    public class DBusServer : Object {
        private static GLib.Once<DBusServer> instance;
        public static unowned DBusServer get_default () {
            return instance.once (() => { return new DBusServer (); });
        }

        public signal void update (Utils.SystemResources data);
        public signal void indicator_state (bool state);
        public signal void quit ();
        public signal void show ();

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

        public void quit_monitor () {
            quit ();
        }

        public void show_monitor () {
            show ();
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
    public errordomain DBusServerError {
        SOME_ERROR
    }
}
