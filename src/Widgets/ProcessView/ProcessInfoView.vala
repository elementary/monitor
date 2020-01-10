public class Monitor.ProcessInfoView : Gtk.HBox {
    public Gtk.Label name;
    public Gtk.Label command;
    public Gtk.Label pid;

    public ProcessInfoView() {

        name = new Gtk.Label(_("N/A"));
        command = new Gtk.Label(_("N/A"));
        pid = new Gtk.Label(_("N/A"));

        add (name);
        add (command);
        add (pid);
    }

    public void update (Process process) {
        pid.set_text (("%d").printf (process.stat.pid));
        debug ("yolo");
    }
}