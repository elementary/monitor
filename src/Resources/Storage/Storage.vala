/*
 * Copyright (c) 2021 Dirli <litandrej85@gmail.com>
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

 public class Monitor.Storage : GLib.Object {

    public int bytes_write;
    private ulong sectors_write_old;

    public int bytes_read;
    private ulong sectors_read_old;

    // flag first run
    // bc first calculasion is wrong
    private bool dumb_flag;

    private UDisks.Client? udisks_client;
    private GLib.List<GLib.DBusObject> obj_proxies;

    private Gee.HashMap<string, Disk?> disks;

    construct {
        bytes_write = 0;
        sectors_write_old = 0;
        bytes_read = 0;
        sectors_read_old = 0;
        dumb_flag = true;

        try {
            udisks_client = new UDisks.Client.sync ();
            var dbus_obj_manager = udisks_client.get_object_manager ();
            obj_proxies = dbus_obj_manager.get_objects ();

            disks = new Gee.HashMap<string, Disk?> ();

            init_drives ();
            init_volumes ();

        } catch (Error e) {
            warning (e.message);
            udisks_client = null;
        }
    }

    private void init_drives () {
        obj_proxies.foreach ((iter) => {
            var udisks_obj = udisks_client.peek_object (iter.get_object_path ());
            if (udisks_obj != null) {
                var p_table = udisks_obj.get_partition_table ();
                if (p_table != null) {
                    var p_type_display = udisks_client.get_partition_table_type_for_display (p_table.type);

                    var part = udisks_obj.get_partition ();

                    var block_device = udisks_obj.get_block ();
                    if (block_device != null) {
                        var obj_icon = udisks_client.get_object_info (udisks_obj).get_icon ();

                        var drive_dev = udisks_client.get_drive_for_block (block_device);
                        if (drive_dev != null) {

                            var current_drive = new Disk (drive_dev);
                            current_drive.device = block_device.device;

                            current_drive.partition = p_type_display != null ? p_type_display : "Unknown";

                            debug ("Found drive: " + current_drive.model + " " + current_drive.revision + " " + current_drive.id + " " + current_drive.device);

                            if (obj_icon != null) {
                                current_drive.drive_icon = obj_icon;
                            }

                            //  var storage_parser = new StorageParser ();
                            //  storage_parser.detect_blocks (current_drive);

                            disks[current_drive.device] = current_drive;
                        }
                    }
                }
            }
        });
    }

    private void init_volumes () {
        obj_proxies.foreach ((iter) => {

            //  var bl = udisks_client.get_block_for_uuid ("a6b16b8f-9153-41c5-b3d8-908e17ed4eda");

            
            //  bl.foreach ((entry) => {
            //      print (entry.device);
            //  });

            var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

            var p_table = udisks_obj.get_partition_table ();
            if (p_table == null) {


                var block_device = udisks_obj.get_block ();

                if (block_device != null && block_device.id_uuid != "") {

                    debug ("path: " + iter.get_object_path ());

                    debug ("  - no partition table");


                    Volume current_volume = new Volume (block_device);

                    var partition = udisks_obj.get_partition ();
                    if (partition != null) {
                        current_volume.offset = partition.offset;
                    }

                    var block_fs = udisks_obj.get_filesystem ();
                    if (block_fs != null && block_fs.mount_points[0] != null) {
                        current_volume.mount_point = block_fs.mount_points[0];
                        Posix.statvfs buf;
                        Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                        current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;

                    // } else {
                    //     current_volume.mount_point = "";
                    }



                    foreach (var disk in disks) {
                        if (current_volume.device.contains (disk.key)) {
                            disk.value.add_volume (current_volume);
                            debug ("Adding volume %s to %s", current_volume.device, disk.key);
                            //  debug ("  - block device: " + block_device.device);
                            //  debug ("  - drive: " + block_device.drive);
                            //  debug ("  - uuid: " + block_device.id_uuid);
                            //  debug ("  - crypto_backing_device: " + block_device.crypto_backing_device);
                            //  debug ("  - id: " + block_device.id);
                            //  debug ("  - id_usage: " + block_device.id_usage);
                            //  debug ("  - id_type: " + block_device.id_type);
                            //  debug ("  - id_label: " + block_device.id_label);
                            //  debug ("  - id_version: " + block_device.id_version);    
                        }
                    }

                }
            }
        });

        foreach (var dd in disks.values) {
            var vv = dd.get_volumes ();
            foreach (var v in vv) {
                debug ("[*] Volume: " + v.device + " " + v.size.to_string () + " " + v.free.to_string ());
            }
        }
    }

    //  public void get_smart (UDisks.Object obj, UDisks.DriveAta ata) {
    //      if (ata.smart_supported) {
    //          var d = obj.get_drive ();

    //          if (d == null) {
    //              return;
    //          }


    //          var did = get_pretty_id (d.id);

    //          if (!disks.has_key (did)) {
    //              return;
    //          }

    //          DriveSmart d_smart = {};

    //          d_smart.enabled = ata.smart_enabled;
    //          d_smart.updated = ata.smart_updated;
    //          d_smart.failing = ata.smart_failing;
    //          d_smart.power_seconds = ata.smart_power_on_seconds;
    //          d_smart.selftest_status = ata.smart_selftest_status;

    //          try {
    //              GLib.Variant var_p = null;
    //              if (ata.call_smart_get_attributes_sync (new GLib.Variant ("a{sv}"), out var_p)) {
    //                  GLib.VariantIter v_iter = var_p.iterator ();
    //                  uchar id;
    //                  int current, worst, threshold, pretty_unit;
    //                  string name;
    //                  uint16 flags;
    //                  uint64 pretty;
    //                  GLib.Variant expansion;
    //                  while (v_iter.next ("(ysqiiixi@a{sv})",
    //                                      out id,
    //                                      out name,
    //                                      out flags,
    //                                      out current,
    //                                      out worst,
    //                                      out threshold,
    //                                      out pretty,
    //                                      out pretty_unit,
    //                                      out expansion)) {

    //                      if (id == 231) {
    //                          d_smart.life_left = (uint) Utils.parse_pretty (pretty, pretty_unit);
    //                      } else if (id == 12) {
    //                          d_smart.power_counts = pretty;
    //                      }
    //                  }

    //                  disks[did].add_smart (d_smart);
    //              }
    //          } catch (Error e) {
    //              warning (e.message);
    //          }
    //      }
    //  }

    public Disk? get_drive (string did) {
        if (disks.has_key (did)) {
            return disks[did];
        }

        return null;
    }

    public Gee.ArrayList<Disk?> get_drives () {
        var drives_arr = new Gee.ArrayList<Disk?> ();
        disks.values.foreach ((d) => {
            drives_arr.add (d);
            return true;
        });

        drives_arr.sort (compare_drives);

        return drives_arr;
    }

    public Gee.ArrayList<Volume?> get_drive_volumes (string dev_id) {
        var volumes_arr = new Gee.ArrayList<Volume?> ();

        if (disks.has_key (dev_id)) {
            disks[dev_id].get_volumes ().foreach ((vol) => {
                volumes_arr.add (vol);

                return true;
            });
        }

        volumes_arr.sort (compare_volumes);

        return volumes_arr;
    }

    //  public Gee.ArrayList<Volume?> get_mounted_volumes () {
    //      var volumes_list = new Gee.ArrayList<Volume?> ();

    //      if (udisks_client != null) {
    //          obj_proxies.foreach ((iter) => {
    //              var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

    //              var p_table = udisks_obj.get_partition_table ();
    //              if (p_table == null) {

    //                  var block_device = udisks_obj.get_block ();
    //                  if (block_device != null && block_device.drive != "/") {
    //                      var block_fs = udisks_obj.get_filesystem ();
    //                      if (block_fs != null && block_fs.mount_points[0] != null) {
    //                          Volume current_volume = {};
    //                          current_volume.device = block_device.device;
    //                          current_volume.label = block_device.id_label;
    //                          current_volume.type = block_device.id_type;
    //                          current_volume.size = block_device.size;
    //                          current_volume.uuid = block_device.id_uuid;
    //                          var partition = udisks_obj.get_partition ();
    //                          if (partition != null) {
    //                              current_volume.offset = partition.offset;
    //                          }

    //                          current_volume.mount_point = block_fs.mount_points[0];
    //                          Posix.statvfs buf;
    //                          Posix.statvfs_exec (block_fs.mount_points[0], out buf);
    //                          current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;

    //                          volumes_list.add (current_volume);
    //                      // } else {
    //                      //     current_volume.mount_point = "";
    //                      }
    //                  }
    //              }
    //          });

    //          volumes_list.sort (compare_volumes);
    //      }

    //      return volumes_list;
    //  }

    public string size_to_display (uint64 size_to_fmt) {
        return udisks_client.get_size_for_display (size_to_fmt, false, false);
    }

    private int compare_drives (Disk? drive1, Disk? drive2) {
        if (drive1 == null) {
            return (drive2 == null) ? 0 : -1;
        }

        if (drive2 == null) {
            return 1;
        }

        return GLib.strcmp (drive1.device, drive2.device);
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

    public void update () {
        ulong sectors_read_new = 0;
        ulong sectors_write_new = 0;

        try {
            string content = null;
            FileUtils.get_contents ("/proc/diskstats", out content);
            InputStream input_stream = new MemoryInputStream.from_data (content.data, GLib.g_free);
            DataInputStream dis = new DataInputStream (input_stream);
            string line;

            while ((line = dis.read_line ()) != null) {
                string[] reg_split = Regex.split_simple ("[ ]+", line);
                if ((reg_split[1] == "8" | reg_split[1] == "252" | reg_split[1] == "259") &&
                Regex.match_simple ("((sd|vd)[a-z]{1}|nvme[0-9]{1}n[0-9]{1})$", reg_split[3])) {
                    sectors_read_new += ulong.parse (reg_split[6]);
                    sectors_write_new += ulong.parse (reg_split[10]);
                }
            }
        } catch (Error e) {
            warning ("Unable to retrieve storage data.");
        }

        // bc 2 sec updates
        if (!dumb_flag) {
            bytes_read = (int) ((sectors_read_new - sectors_read_old) * 512 / 2);
            bytes_write = (int) ((sectors_write_new - sectors_write_old) * 512 / 2);
        }
        dumb_flag = false;

        sectors_read_old = sectors_read_new;
        sectors_write_old = sectors_write_new;
    }
}
