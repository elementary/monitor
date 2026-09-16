/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.LogView : Granite.Bin {
    private SystemdLogModel model;
    private Gtk.ProgressBar refresh_progress;
    private Gtk.Revealer refresh_revealer;
    private uint refresh_timeout = -1;

    construct {
        refresh_progress = new Gtk.ProgressBar ();

        refresh_revealer = new Gtk.Revealer () {
            child = refresh_progress
        };

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

        var box = new Granite.Box (VERTICAL, NONE);
        box.append (refresh_revealer);
        box.append (scrolled);

        child = box;

        scrolled.edge_reached.connect (on_edge_reached);
        scrolled.edge_overshot.connect (on_edge_overshot);
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

    public void on_search_changed (string needle) {
        model.search (needle);
    }

    private void on_edge_reached (Gtk.PositionType pos) {
        if (pos == BOTTOM) {
            model.load_chunk ();
        }
    }

    private void on_edge_overshot (Gtk.PositionType pos) {
        if (pos == TOP) {
            if (refresh_timeout == -1) {
                refresh_timeout = Timeout.add_once (200, () => {
                    reset_refresh_progress ();
                });
            }

            refresh_revealer.reveal_child = true;
            refresh_progress.fraction += 0.25;

            if (refresh_progress.fraction >= 1) {
                model.refresh ();
                reset_refresh_progress ();
            }
        }
    }

    private void reset_refresh_progress () {
        refresh_revealer.reveal_child = false;
        refresh_progress.fraction = 0;
        refresh_timeout = -1;
    }
}
