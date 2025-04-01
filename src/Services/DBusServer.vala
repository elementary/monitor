/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

[DBus (name = "io.elementary.monitor")]
public class Monitor.DBusServer : Object {
    private const string DBUS_NAME = "io.elementary.monitor";
    private const string DBUS_PATH = "/io/elementary/monitor";

    private static GLib.Once<DBusServer> instance;

    public static unowned DBusServer get_default () {
        return instance.once (() => { return new DBusServer (); });
    }

    public signal void update (ResourcesSerialized data);
    public signal void indicator_state (bool state);
    public signal void indicator_cpu_state (bool state);
    public signal void indicator_cpu_frequency_state (bool state);
    public signal void indicator_cpu_temperature_state (bool state);
    public signal void indicator_memory_state (bool state);
    public signal void indicator_network_up_state (bool state);
    public signal void indicator_network_down_state (bool state);
    public signal void indicator_gpu_state (bool state);
    public signal void indicator_gpu_memory_state (bool state);
    public signal void indicator_gpu_temperature_state (bool state);
    public signal void quit ();
    public signal void show ();

    construct {
        Bus.own_name (
            BusType.SESSION,
            DBUS_NAME,
            BusNameOwnerFlags.NONE,
            (connection) => on_bus_aquired (connection),
            () => {},
            null
            );
    }

    public void quit_monitor () throws IOError, DBusError {
        quit ();
    }

    public void show_monitor () throws IOError, DBusError {
        show ();
    }

    private void on_bus_aquired (DBusConnection conn) {
        try {
            debug ("DBus registered!");
            conn.register_object ("/io/elementary/monitor", get_default ());
        } catch (Error e) {
            error (e.message);
        }
    }

}

[DBus (name = "io.elementary.monitor")]
public errordomain DBusServerError {
    SOME_ERROR
}
