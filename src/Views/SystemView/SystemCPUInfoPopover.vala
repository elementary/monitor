public class Monitor.SystemCPUInfoPopover : Gtk.Box {
    private CPU cpu;

    construct {
        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
    }


    public SystemCPUInfoPopover (CPU _cpu) {

        cpu = _cpu;

        var stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT,
            height_request = 300,
            width_request = 400,
            margin_top = 12,
        };

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
        var label = new Gtk.Label (text) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.START,
            wrap = true,
            margin = 6,
        };

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

        foreach (var bug in cpu.bugs) {
            listbox.add (create_row (bug.key, bug.value));
        }

        var scrolled_window = new Gtk.ScrolledWindow (null, null);
        scrolled_window.add (listbox);

        return scrolled_window;
    }

    private Gtk.ListBoxRow create_row (string flag, string flag_description) {
        var row = new Gtk.ListBoxRow ();
        var grid = new Gtk.Grid (){
            column_spacing = 2,
            margin_bottom = 12
        };

        var flag_label = new Gtk.Label (flag) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER,
            wrap = true,
            margin = 6,
        };
        flag_label.get_style_context ().add_class ("flags_badge");


        grid.attach (flag_label, 0, 0, 1, 1);
        grid.attach (label (flag_description), 0, 1, 1, 1);
        row.add (grid);

        return row;
    }

}

//  public class Monitor.X : Gtk.ListBoxRow {
//      construct {
//          get_style_context ().add_class ("open_files_list_box_row");
//      }
//      public X (string _text) {
//          var text = _text;
//          var grid = new Gtk.Grid ();
//          grid.column_spacing = 2;

//          Gtk.Label label = new Gtk.Label (text);
//          label.halign = Gtk.Align.START;
//          grid.attach (label, 1, 0, 1, 1);

//          add (grid);
//      }
//  }