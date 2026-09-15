/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.SystemdLogModel : GLib.Object, GLib.ListModel, Gtk.SectionModel {
    private static DateTime? now;

    public static DateTime get_stable_now () {
        return now;
    }

    private const int CHUNK_SIZE = 200;
    private const int64 CHUNK_TIME = 1000; // 1 millisecond

    private Systemd.Journal journal;
    private Systemd.Id128 current_boot_id;
    private uint64 current_tail_time = 0;
    private string current_search_term = "";

    // These fields are for the listmodel and section model implementation
    // and only used for loading and in the implementations
    private Gee.ArrayList<SystemdLogEntry> entries;
    private bool eof = false;
    private bool loading = false;
    private int current_section_start = 0;
    private DateTime? current_section_time;
    private HashTable<uint, uint> section_end_for_start = new HashTable<uint, uint> (null, null);

    construct {
        entries = new Gee.ArrayList<SystemdLogEntry> ();

        int res = Systemd.Journal.open_namespace (out journal, null, LOCAL_ONLY);
        if (res != 0) {
            critical ("%s", strerror (-res));
            return;
        }

        res = Systemd.Id128.boot (out current_boot_id);
        if (res != 0) {
            critical ("%s", strerror (-res));
            return;
        }

        init ();
    }

    private void reset () {
        if (!entries.is_empty) {
            var removed = entries.size;
            entries.clear ();
            items_changed (0, removed, 0);
        }

        eof = false;
        loading = false; // Cancels ongoing load
        current_section_start = 0;
        current_section_time = null;
        section_end_for_start.remove_all ();

        journal.flush_matches ();
    }

    private void init () {
        now = new DateTime.now_utc ();

        //TODO: Add exact matches, allow to filter by boot
        journal.add_match ("_BOOT_ID=%s".printf (current_boot_id.str).data);
        journal.add_conjunction ();

        if (current_tail_time == 0) {
            journal.seek_tail ();
            journal.previous ();
            int res = journal.get_realtime_usec (out current_tail_time);
            if (res != 0) {
                critical ("Failed to get tail realtime: %s", strerror (-res));
                return;
            }
        } else {
            journal.seek_realtime_usec (current_tail_time);
            journal.previous ();
        }

        load_chunk ();
    }

    public void load_chunk () {
        if (eof || loading) {
            return;
        }

        loading = true;

        var start_items = get_n_items ();

        Idle.add (() => {
            if (!loading) { // We were cancelled
                return Source.REMOVE;
            }

            load_timed ();
            loading = !eof && get_n_items () - start_items < CHUNK_SIZE;
            return loading ? Source.CONTINUE : Source.REMOVE;
        });
    }

    private void load_timed () {
        if (eof) {
            return;
        }

        var start_n_items = entries.size;
        var start_time = get_monotonic_time ();

        while (get_monotonic_time () - start_time < CHUNK_TIME) {
            if (!load_next_entry ()) {
                eof = true;
                break;
            }
        }

        items_changed (start_n_items, 0, entries.size - start_n_items);
    }

    private bool load_next_entry () {
        int res = journal.previous ();
        if (res == 0) {
            return false;
        }

        if (res < 0) {
            critical ("Failed to go to next aka previous entry: %s", strerror (-res));
            return false;
        }

        unowned uint8[] data;
        unowned uint8[] comm_data;
        res = journal.get_data ("MESSAGE", out data);
        if (res != 0) {
            critical ("Failed to get message: %s", strerror (-res));
            return true; // Don't eof just skip it
        }

        res = journal.get_data ("_COMM", out comm_data);
        if (res != 0) {
            comm_data = "_COMM=kernel".data;
        }

        var origin = ((string) comm_data).offset ("_COMM=".length);
        var message = ((string) data).offset ("MESSAGE=".length);

        uint64 time;
        res = journal.get_realtime_usec (out time);
        if (res != 0) {
            critical ("Failed to get time: %s", strerror (-res));
            time = 0;
        }

        var dt = new DateTime.from_unix_utc ((int64) (time / TimeSpan.SECOND));

        var entry = new SystemdLogEntry (origin, message, dt);

        // Filter if we're searching. We drop them and don't add them and use a filter model
        // because when searching for e.g. a non existent term this would fill up memory *quick*
        if (current_search_term.strip () != "" && !entry.matches (current_search_term)) {
            return true;
        }

        // Update sections (group entries that have a timestamp from the same second)
        if (!update_current_range (dt)) {
            section_end_for_start[current_section_start] = entries.size;
            current_section_start = entries.size;
        }
        entry.section_start = current_section_start;

        entries.add (entry);

        return true;
    }

    private bool update_current_range (DateTime dt) {
        if (current_section_time == null) {
            current_section_time = dt;
            return true;
        }

        if (current_section_time.difference (dt) <= TimeSpan.SECOND) {
            return true;
        } else {
            current_section_time = dt;
            return false;
        }
    }

    public void search (string term) {
        reset ();
        //TODO: tokenize etc.
        current_search_term = term;
        init ();
    }

    public void refresh () {
        reset ();
        current_tail_time = 0;
        init ();
    }

    public Object? get_item (uint position) {
        if (position >= entries.size) {
            return null;
        } else {
            return entries[(int) position];
        }
    }

    public Type get_item_type () {
        return typeof (SystemdLogEntry);
    }

    public uint get_n_items () {
        return entries.size;
    }

    public void get_section (uint for_position, out uint section_start, out uint section_end) {
        if (for_position >= entries.size) {
            // Documentation mandates this
            section_start = entries.size;
            section_end = uint.MAX;
            return;
        }

        section_start = entries[(int) for_position].section_start;

        if (section_start in section_end_for_start) {
            section_end = section_end_for_start[section_start];
        } else {
            section_end = entries.size;
        }
    }
}
