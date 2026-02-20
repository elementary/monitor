/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.OpenFilesTreeView : Granite.Bin {
    private GLib.ListStore model;

    public signal void process_selected (Process process);

    public OpenFilesTreeView () {
        model = new GLib.ListStore (typeof (Monitor.OpenFile));
        var selection_model = new Gtk.NoSelection (model);

        var path_column_factory = new Gtk.SignalListItemFactory ();
        path_column_factory.setup.connect (on_path_column_setup);
        path_column_factory.bind.connect (on_path_column_bind);

        var path_column = new Gtk.ColumnViewColumn (_("Opened files"), path_column_factory) {
            expand = true,
        };

        var column_view = new Gtk.ColumnView (selection_model);
        column_view.append_column (path_column);

        vexpand = true;

        child = new Gtk.ScrolledWindow () {
            child = column_view,
            max_content_height = 250, 
        };
    }

    private void on_path_column_setup (Gtk.SignalListItemFactory factory, GLib.Object list_item_obj) {
        var label = new Gtk.Label ("");
        label.halign = Gtk.Align.START;
        ((Gtk.ListItem) list_item_obj).child = label;
    }

    private void on_path_column_bind (Gtk.SignalListItemFactory factory, GLib.Object list_item_obj) {
        var list_item = (Gtk.ListItem) list_item_obj;
        var item_data = (OpenFile) list_item.item;
        var label = (Gtk.Label) list_item.child;
        label.label = item_data.path;
    }

    public void update (Process process) {
        model.remove_all ();
        foreach (var path in process.open_files_paths) {
            model.append (new OpenFile (path));
        }
    }

}
