/*
 * Copyright (c) 2020 Dirli <litandrej85@gmail.com>
 * Copyright (c) 2021 stsdc
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

public struct Monitor.DriveSmart {
    public bool enabled;
    public uint64 updated;
    public bool failing;
    public uint64 power_seconds;
    public uint64 power_counts;
    public string selftest_status;
    public uint life_left;
}



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

