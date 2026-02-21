/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.OpenFile : GLib.Object {
    public string path { get; set; }

    public OpenFile (string path) {
        Object (path: path);
    }

}