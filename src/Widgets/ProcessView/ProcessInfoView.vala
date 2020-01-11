public class Monitor.ProcessInfoView : Gtk.Grid {
    public Gtk.Label application_name;
    public string ? icon_name;
    public Gtk.Label command;
    public Gtk.Label pid;

    private Gtk.Grid grid;

    public ProcessInfoView() {
        margin = 12;

        var icon = new Gtk.Image.from_icon_name ("application-x-executable", Gtk.IconSize.DIALOG);
        icon.valign = Gtk.Align.END;

        application_name = new Gtk.Label(_("N/A"));
        application_name.get_style_context ().add_class ("h2");

        command = new Gtk.Label(_("N/A"));
        command.halign = Gtk.Align.START;

        pid = new Gtk.Label(_("N/A"));

        //  add (name);
        //  add (command);
        //  add (pid);

        grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("horizontal");
        grid.column_spacing = 12;

        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (application_name, 1, 0, 1, 1);
        grid.attach (command, 1, 1, 1, 1);

        add (grid);
    }

    public void update (Process process) {
        application_name.set_text (("%s").printf (process.application_name));
        //  debug ("%s, %s", process.command, process.app_info.get_name ());
        pid.set_text (("%d").printf (process.stat.pid));
    }
}