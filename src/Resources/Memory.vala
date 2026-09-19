/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

namespace Monitor {
    public class Memory : Object {
        public double total = 0;
        public double used = 0;
        public double shared;
        public double buffer;
        public double cached;
        public double locked;

        private GTop.Memory mem;

        public uint used_percentage {
            get {
                return (uint) (Math.round ((used / total) * 100));
            }
        }

        public uint shared_percentage {
            get {
                return (uint) (Math.round ((shared / used) * 100));
            }
        }

        public uint buffer_percentage {
            get {
                return (uint) (Math.round ((buffer / used) * 100));
            }
        }

        public uint cached_percentage {
            get {
                return (uint) (Math.round ((cached / used) * 100));
            }
        }

        public uint locked_percentage {
            get {
                return (uint) (Math.round ((locked / used) * 100));
            }
        }

        public void update () {
            GTop.get_mem (out mem);
            var total_physical_memory = get_total_physical_memory ();
            total = (double) (total_physical_memory > 0 ? total_physical_memory : mem.total);
            used = (double) mem.user;
            shared = (double) (mem.shared);
            buffer = (double) (mem.buffer);
            cached = (double) (mem.cached);
            locked = (double) (mem.locked);
        }

        private uint64 get_total_physical_memory () {
            uint64 mem_total = 0;

            GUdev.Client client = new GUdev.Client ({"dmi"});
            GUdev.Device? device = client.query_by_sysfs_path ("/sys/devices/virtual/dmi/id");

            if (device != null) {
                uint64 devices = device.get_property_as_uint64 ("MEMORY_ARRAY_NUM_DEVICES");
                for (int item = 0; item < devices; item++) {
                    mem_total += device.get_property_as_uint64 ("MEMORY_DEVICE_%d_SIZE".printf (item));
                }
            }

            return mem_total;
        }
    }
}
