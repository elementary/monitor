public class Monitor.SystemCPUInfoPopover : Gtk.Box {
    private CPU cpu;

    construct {
        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
    }


    public SystemCPUInfoPopover (CPU _cpu) {

        cpu = _cpu;

        var stack = new Gtk.Stack ();
        stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

        stack.add_titled (general_page (), "general_page", _("General"));
        stack.add_titled (flags_page (), "flags_page", _("Flags"));
        stack.add_titled (bugs_page (), "bugs_page", _("Bugs"));

        Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher (){
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER,
        };
        stack_switcher.set_stack (stack);

        add (stack_switcher);
        add (stack);
    }

    private Gtk.Label label (string text) {
        var label = new Gtk.Label (text);
        label.halign = Gtk.Align.START;
        label.valign = Gtk.Align.START;
        label.wrap = true;
        label.max_width_chars = 80;

        return label;
    }

    private Gtk.ListBox general_page () {
        var listbox = new Gtk.ListBox () {
            activate_on_single_click = false
        };

        listbox.add (label (_("Model:") + " " + cpu.model));
        listbox.add (label (_("Family:") + " " + cpu.family));
        listbox.add (label (_("Microcode ver.:") + " " + cpu.microcode));
        listbox.add (label (_("Bogomips:") + " " + cpu.bogomips));
        listbox.add (label (_("Cache size:") + " " + cpu.cache_size));
        listbox.add (label (_("Address sizes:") + " " + cpu.address_sizes));

        return listbox;
    }

    private Gtk.Widget flags_page () {
        var listbox = new Gtk.ListBox () {
            activate_on_single_click = false
        };

        foreach (unowned string flag in cpu.flags) {
            listbox.add (label (flag));
        }

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        return scrolled_window;
    }

    private Gtk.Widget bugs_page () {
        var listbox = new Gtk.ListBox () {
            activate_on_single_click = false
        };

        foreach (unowned string bug in cpu.bugs) {
            listbox.add (label (bug));
        }

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        return scrolled_window;
    }

}
