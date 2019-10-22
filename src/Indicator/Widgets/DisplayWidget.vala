public class Monitor.Widgets.DisplayWidget : Gtk.Grid {
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
