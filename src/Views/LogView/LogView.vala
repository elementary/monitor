/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.LogView : Granite.Bin {
    private SystemdLogModel model;

    construct {

        var search_entry = new Gtk.SearchEntry () {
            hexpand = true,
            placeholder_text = _("Search")
        };

        var refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic") {
            tooltip_text = _("Load new entries")
        };

        var top_box = new Granite.Box (HORIZONTAL) {
            margin_top = 12,
            margin_end = 12,
            margin_start = 12
        };
        top_box.append (search_entry);
        top_box.append (refresh_button);

        model = new SystemdLogModel ();

        var selection_model = new Gtk.NoSelection (model);

        var header_factory = new Gtk.SignalListItemFactory ();
        header_factory.setup.connect (setup_header);
        header_factory.bind.connect (bind_header);

        var origin_factory = new Gtk.SignalListItemFactory ();
        origin_factory.setup.connect (setup_origin);
        origin_factory.bind.connect (bind);

        var origin_column = new Gtk.ColumnViewColumn (_("Sender"), origin_factory);

        var message_factory = new Gtk.SignalListItemFactory ();
        message_factory.setup.connect (setup_message);
        message_factory.bind.connect (bind);

        var message_column = new Gtk.ColumnViewColumn (_("Message"), message_factory) {
            expand = true
        };

        var column_view = new Gtk.ColumnView (selection_model) {
            header_factory = header_factory,
            reorderable = false,
            vexpand = true
        };
        column_view.append_column (origin_column);
        column_view.append_column (message_column);

        var scrolled = new Gtk.ScrolledWindow () {
            child = column_view
        };

        var box = new Granite.Box (VERTICAL);
        box.append (top_box);
        box.append (search_entry);
        box.append (scrolled);

        child = box;

        refresh_button.clicked.connect (model.refresh);
        search_entry.search_changed.connect (on_search_changed);
        scrolled.edge_reached.connect (on_edge_reached);
    }

    private void setup_header (Object obj) {
        var item = (Gtk.ListHeader) obj;
        item.child = new Granite.HeaderLabel ("");
    }

    private void bind_header (Object obj) {
        var item = (Gtk.ListHeader) obj;
        var entry = (SystemdLogEntry) item.item;
        var label = (Granite.HeaderLabel) item.child;
        label.label = entry.relative_time;
    }

    private void setup_origin (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new LogCell (ORIGIN);
    }

    private void setup_message (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new LogCell (MESSAGE);
    }

    private void bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var entry = (SystemdLogEntry) item.item;
        var cell = (LogCell) item.child;
        cell.bind (entry);
    }

    private void on_search_changed (Gtk.SearchEntry entry) {
        model.search (entry.text);
    }

    private void on_edge_reached (Gtk.PositionType pos) {
        if (pos == BOTTOM) {
            model.load_chunk ();
        }
    }
}
