namespace Monitor {

    public class Updater : Object {
        private int interval = 2; // in secs

        public signal void update ();

        construct {
            Timeout.add_seconds (interval, handle_timeout);
        }

        private bool handle_timeout () {
            update ();
            return true;
        }
    }
}
