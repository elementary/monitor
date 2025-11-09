/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Volume : Object {
    public string device;
    public string label;
    public string type;
    public string uuid;
    public string mount_point;
    public uint64 size;
    public uint64 free;
    public uint64 offset;

    // means the volume is only on one physical disk
    public bool strict_affiliation { public get; private set; }

    public Gee.ArrayList<string?> slaves = new Gee.ArrayList <string?> ();


    public Volume (UDisks.Block block) {
        device = block.device;
        label = block.id_label;
        type = block.id_type;
        size = block.size;
        uuid = block.id_uuid;
    }

    public void add_slave (string? new_slave) {
        check_affiliation (new_slave);
        slaves.add (new_slave);
    }

    private void check_affiliation (string new_slave) {
        if (slaves.size > 0) {
            foreach (string slave in slaves) {
                if (slave.contains (new_slave[0:3])) {
                    strict_affiliation = true;
                    debug ("Slave volume %s of %s is on the same disk as all other slave volumes", new_slave, device);
                } else {
                    strict_affiliation = false;
                    debug ("Slave volume %s of %s is on the same disk as all other slave volumes", new_slave, device);
                }
            }
        } else {
            debug ("First slave: %s", new_slave);
            strict_affiliation = true;
        }
    }
}
