namespace elementarySystemMonitor {

    public class App : Process {
        // App Window ID
        public int xid { get; private set; }
        public string name { get; private set; }
        public string icon { get; private set; }
        public string? desktop_file { get; private set; }
        public int[] win_pids { get; private set; }

        // Construct a new process
        public App (Bamf.Application app, int[] _pids) {
            name = app.get_name (),
            icon = app.get_icon (),
            desktop_file = app.get_desktop_file (),
            this.win_pids = win_pids[0];
        }
    }
}
