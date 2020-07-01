namespace Monitor {

    public class Updater : Object {
        private static GLib.Once<Updater> instance;
        public static unowned Updater get_default () {
            return instance.once (() => { return new Updater (); });
        }

        private int interval = 2; // in secs

        private Resources resources;

        public signal void update (Resources resources);

        construct {
            resources = new Resources ();
            Timeout.add_seconds (interval, () => {
                update (resources);
                return true;
            });
        }
    }
}
