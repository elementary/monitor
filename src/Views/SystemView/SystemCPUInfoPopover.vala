public class Monitor.SystemCPUInfoPopover : Gtk.Popover {
    private Gtk.Grid grid;

    private CPU cpu;

    construct {
        grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.column_spacing = 6;

        grid.attach (label (_("Model")), 0, 0, 1, 1);
        grid.attach (label (_("Family")), 0, 1, 1, 1);
        grid.attach (label (_("Microcode ver.")), 0, 2, 1, 1);
        grid.attach (label (_("Bogomips")), 0, 3, 1, 1);
        grid.attach (label (_("Cache size")), 0, 4, 1, 1);
        grid.attach (label (_("Address sizes")), 0, 5, 1, 1);
        grid.attach (label (_("Flags")), 0, 6, 1, 1);
        grid.attach (label (_("Bugs")), 0, 7, 1, 1);

        for (int i; i <= 7; i++) {
            grid.attach (label (":"), 1, i, 1, 1);
        }

        add (grid);
    }


    public SystemCPUInfoPopover (Gtk.ToggleButton ? relative_to, CPU _cpu) {
        Object (relative_to: relative_to);

        closed.connect (() => { relative_to.set_active (false); });

        cpu = _cpu;

        grid.attach (label (cpu.model), 2, 0, 1, 1);
        grid.attach (label (cpu.family), 2, 1, 1, 1);
        grid.attach (label (cpu.microcode), 2, 2, 1, 1);
        grid.attach (label (cpu.bogomips), 2, 3, 1, 1);
        grid.attach (label (cpu.cache_size), 2, 4, 1, 1);
        grid.attach (label (cpu.address_sizes), 2, 5, 1, 1);
        grid.attach (label (cpu.flags), 2, 6, 1, 1);
        grid.attach (label (cpu.bugs), 2, 7, 1, 1);
    }

    private Gtk.Label label (string text) {
        var label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;
        label.valign = Gtk.Align.START;
        label.wrap = true;
        label.max_width_chars = 80;

        return label;
    }

}
