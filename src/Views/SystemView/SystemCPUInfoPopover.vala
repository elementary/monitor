public class Monitor.SystemCPUInfoPopover : Gtk.Grid {
    private CPU cpu;

    construct {
        margin = 12;
        column_spacing = 6;

        attach (label (_("Model")), 0, 0, 1, 1);
        attach (label (_("Family")), 0, 1, 1, 1);
        attach (label (_("Microcode ver.")), 0, 2, 1, 1);
        attach (label (_("Bogomips")), 0, 3, 1, 1);
        attach (label (_("Cache size")), 0, 4, 1, 1);
        attach (label (_("Address sizes")), 0, 5, 1, 1);
        attach (label (_("Flags")), 0, 6, 1, 1);
        attach (label (_("Bugs")), 0, 7, 1, 1);

        for (int i; i <= 7; i++) {
            attach (label (":"), 1, i, 1, 1);
        }
    }


    public SystemCPUInfoPopover (CPU _cpu) {

        cpu = _cpu;

        attach (label (cpu.model), 2, 0, 1, 1);
        attach (label (cpu.family), 2, 1, 1, 1);
        attach (label (cpu.microcode), 2, 2, 1, 1);
        attach (label (cpu.bogomips), 2, 3, 1, 1);
        attach (label (cpu.cache_size), 2, 4, 1, 1);
        attach (label (cpu.address_sizes), 2, 5, 1, 1);
        attach (label (cpu.flags), 2, 6, 1, 1);
        attach (label (cpu.bugs), 2, 7, 1, 1);
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
