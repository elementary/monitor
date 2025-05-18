/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.SystemCPUInfoPopover : Gtk.Box {
    private CPU cpu;

    construct {
        margin_top = 12;
        margin_bottom = 12;
        margin_start = 12;
        margin_end = 12;
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
        stack.add_titled (features_page (), "features_page", _("Features"));
        stack.add_titled (bugs_page (), "bugs_page", _("Bugs"));

        Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher () {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER,
        };
        stack_switcher.set_stack (stack);

        append (stack_switcher);
        append (stack);
    }

    private Gtk.Label label (string text) {
        var label = new Gtk.Label (text) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER,
            wrap = true,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6,
        };

        return label;
    }

    private Gtk.ListBox general_page () {
        var listbox = new Gtk.ListBox () {
            activate_on_single_click = false
        };

        listbox.append (label (_("Model:") + " " + cpu.model));
        listbox.append (label (_("Family:") + " " + cpu.family));
        listbox.append (label (_("Microcode ver.:") + " " + cpu.microcode));
        listbox.append (label (_("Bogomips:") + " " + cpu.bogomips));

        if (cpu.core_list[0].caches.has_key ("L1Instruction")) {
            var value = cpu.cache_multipliers["L1Instruction"].to_string () + "×" + cpu.core_list[0].caches["L1Instruction"].size;
            listbox.append (label (_("L1 Instruction cache: ") + value));
        }
        if (cpu.core_list[0].caches.has_key ("L1Data")) {
            var value = cpu.cache_multipliers["L1Data"].to_string () + "×" + cpu.core_list[0].caches["L1Data"].size;
            listbox.append (label (_("L1 Data cache: ") + value));
        }
        if (cpu.core_list[0].caches.has_key ("L1")) {
            var value = cpu.cache_multipliers["L1"].to_string () + "×" + cpu.core_list[0].caches["L1"].size;
            listbox.append (label (_("L1 cache: ") + value));
        }
        if (cpu.core_list[0].caches.has_key ("L2")) {
            listbox.append (label (_("L2 Cache size: ") + cpu.cache_multipliers["L2"].to_string () + "×" + cpu.core_list[0].caches["L2"].size));
        }
        if (cpu.core_list[0].caches.has_key ("L3")) {
            listbox.append (label (_("L3 Cache size: ") + cpu.cache_multipliers["L3"].to_string () + "×" + cpu.core_list[0].caches["L3"].size));
        }

        listbox.append (label (_("Address sizes: ") + cpu.address_sizes));

        return listbox;
    }

    private Gtk.Widget features_page () {
        var listbox = new Gtk.ListBox () {
            activate_on_single_click = false
        };

        foreach (var feature in cpu.features) {
            listbox.append (create_row (feature.key, feature.value));
        }

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = listbox
        };

        return scrolled_window;
    }

    private Gtk.Widget bugs_page () {
        var listbox = new Gtk.ListBox () {
            activate_on_single_click = false
        };

        foreach (var bug in cpu.bugs) {
            listbox.append (create_row (bug.key, bug.value));
        }

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = listbox
        };

        return scrolled_window;
    }

    private Gtk.ListBoxRow create_row (string flag, string flag_description) {
        var row = new Gtk.ListBoxRow ();
        var grid = new Gtk.Grid () {
            column_spacing = 2,
        };

        var flag_label = new Gtk.Label (flag) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.CENTER,
            wrap = true,
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6,
        };
        flag_label.add_css_class ("flags_badge");


        grid.attach (flag_label, 0, 0, 1, 1);
        grid.attach (label (flag_description), 1, 0, 1, 1);
        row.set_child (grid);

        return row;
    }

}

// public class Monitor.X : Gtk.ListBoxRow {
// construct {
// get_style_context ().add_class ("open_files_list_box_row");
// }
// public X (string _text) {
// var text = _text;
// var grid = new Gtk.Grid ();
// grid.column_spacing = 2;

// Gtk.Label label = new Gtk.Label (text);
// label.halign = Gtk.Align.START;
// grid.attach (label, 1, 0, 1, 1);

// add (grid);
// }
// }
