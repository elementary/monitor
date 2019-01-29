public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
    private Gtk.Revealer percent_revealer;
    private bool allow_percent = false;

    public CPUWidget cpu_widget;
    public MemoryWidget memory_widget;

    construct {
        valign = Gtk.Align.CENTER;

        cpu_widget = new CPUWidget ();

        memory_widget = new MemoryWidget ();

        add (cpu_widget);
        add (memory_widget);

    }
}
