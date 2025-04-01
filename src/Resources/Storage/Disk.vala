/*
 * Copyright 2021 Dirli <litandrej85@gmail.com>
 *           2021 stsdc
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Monitor.Disk : GLib.Object {
    public string model;
    public uint64 size;
    public uint64 free;
    public string revision;
    public string id;
    public string device;
    public string partition;
    public GLib.Icon drive_icon;

    private Gee.ArrayList<Volume?> volumes = new Gee.ArrayList <Volume?> ();

    public Disk (UDisks.Drive drive) {
        model = drive.model;
        size = drive.size;
        revision = drive.revision;
        id = drive.id;
        free = 0;
    }

    public void add_volume (Volume vol) {
        volumes.add (vol);
        free = free + vol.free;
    }

    public Gee.ArrayList<Volume?> get_volumes () {
        var volumes_arr = new Gee.ArrayList<Volume?> ();

        volumes.foreach ((vol) => {

            volumes_arr.add (vol);

            return true;
        });

        volumes_arr.sort (compare_volumes);

        return volumes_arr;
    }

    private int compare_volumes (Volume? vol1, Volume? vol2) {
        if (vol1 == null) {
            return (vol2 == null) ? 0 : -1;
        }

        if (vol2 == null) {
            return 1;
        }

        return GLib.strcmp (vol1.device, vol2.device);
    }
}
