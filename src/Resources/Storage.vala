public class Monitor.Storage : GLib.Object {

    private UDisks.Client? udisks_client;
    private GLib.List<GLib.DBusObject> obj_proxies;

    private Gee.HashMap<string, DiskDrive?> drives_hash;

    public Storage () {
        try {
            udisks_client = new UDisks.Client.sync ();
            var dbus_obj_manager = udisks_client.get_object_manager ();
            obj_proxies = dbus_obj_manager.get_objects ();
        } catch (Error e) {
            warning (e.message);
            udisks_client = null;
        }
    }

    public bool init () {
        if (udisks_client == null) {
            return false;
        }

        drives_hash = new Gee.HashMap<string, DiskDrive?> ();

        init_drives ();
        init_volumes ();

        return true;
    }

    private void init_drives () {
        obj_proxies.foreach ((iter) => {
            var udisks_obj = udisks_client.peek_object (iter.get_object_path ());
            if (udisks_obj != null) {
                var p_table = udisks_obj.get_partition_table ();
                if (p_table != null) {
                    var p_type_display = udisks_client.get_partition_table_type_for_display (p_table.type);

                    var block_dev = udisks_obj.get_block ();
                    if (block_dev != null) {
                        var obj_icon = udisks_client.get_object_info (udisks_obj).get_icon ();

                        var drive_dev = udisks_client.get_drive_for_block (block_dev);
                        if (drive_dev != null) {
                            var current_drive = new DiskDrive ();

                            current_drive.model = drive_dev.model;
                            current_drive.size = drive_dev.size;
                            current_drive.revision = drive_dev.revision;

                            if (drive_dev.id == "") {
                                current_drive.id = "";
                            } else {
                                var dev_id = drive_dev.id.split("-");
                                current_drive.id = dev_id[dev_id.length - 1];
                            }
                            current_drive.device = block_dev.device;
                            current_drive.partition = p_type_display != null ? p_type_display : "Unknown";

                            if (obj_icon != null) {
                                current_drive.drive_icon = obj_icon;
                            }

                            drives_hash[current_drive.id] = current_drive;
                        }
                    }
                }
            }
        });
    }

    private void init_volumes () {
        obj_proxies.foreach ((iter) => {
            var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

            var ata = udisks_obj.get_drive_ata ();
            if (ata != null) {
                //  get_smart (udisks_obj, ata);
            }

            var p_table = udisks_obj.get_partition_table ();
            if (p_table == null) {

                var block_dev = udisks_obj.get_block ();
                if (block_dev != null && block_dev.drive != "/") {
                    MonitorVolume current_volume = {};
                    current_volume.device = block_dev.device;
                    current_volume.label = block_dev.id_label;
                    current_volume.type = block_dev.id_type;
                    current_volume.size = block_dev.size;
                    current_volume.uuid = block_dev.id_uuid;
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

                    var d = udisks_client.get_drive_for_block (block_dev);
                    if (d != null) {
                        var dev_id = d.id.split("-");
                        var did = dev_id[dev_id.length - 1];
                        if (drives_hash.has_key (did) && block_dev.device.contains (drives_hash[did].device)) {
                            drives_hash[did].add_volume (current_volume);
                        }
                    }
                }
            }
        });
    }

    //  public void get_smart (UDisks.Object obj, UDisks.DriveAta ata) {
    //      if (ata.smart_supported) {
    //          var d = obj.get_drive ();

    //          if (d == null) {
    //              return;
    //          }

    //          var id_arr = d.id.split("-");
    //          var did = id_arr[id_arr.length - 1];

    //          if (!drives_hash.has_key (did)) {
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

    //                  drives_hash[did].add_smart (d_smart);
    //              }
    //          } catch (Error e) {
    //              warning (e.message);
    //          }
    //      }
    //  }

    public DiskDrive? get_drive (string did) {
        if (drives_hash.has_key (did)) {
            return drives_hash[did];
        }

        return null;
    }

    public Gee.ArrayList<DiskDrive?> get_drives () {
        var drives_arr = new Gee.ArrayList<DiskDrive?> ();
        drives_hash.values.foreach ((d) => {
            drives_arr.add (d);
            return true;
        });

        drives_arr.sort (compare_drives);

        return drives_arr;
    }

    public Gee.ArrayList<MonitorVolume?> get_drive_volumes (string dev_id) {
        var volumes_arr = new Gee.ArrayList<MonitorVolume?> ();

        if (drives_hash.has_key (dev_id)) {
            drives_hash[dev_id].get_volumes ().foreach ((vol) => {
                volumes_arr.add (vol);

                return true;
            });
        }

        volumes_arr.sort (compare_volumes);

        return volumes_arr;
    }

    public Gee.ArrayList<MonitorVolume?> get_mounted_volumes () {
        var volumes_list = new Gee.ArrayList<MonitorVolume?> ();

        if (udisks_client != null) {
            obj_proxies.foreach ((iter) => {
                var udisks_obj = udisks_client.peek_object (iter.get_object_path ());

                var p_table = udisks_obj.get_partition_table ();
                if (p_table == null) {

                    var block_dev = udisks_obj.get_block ();
                    if (block_dev != null && block_dev.drive != "/") {
                        var block_fs = udisks_obj.get_filesystem ();
                        if (block_fs != null && block_fs.mount_points[0] != null) {
                            MonitorVolume current_volume = {};
                            current_volume.device = block_dev.device;
                            current_volume.label = block_dev.id_label;
                            current_volume.type = block_dev.id_type;
                            current_volume.size = block_dev.size;
                            current_volume.uuid = block_dev.id_uuid;
                            var partition = udisks_obj.get_partition ();
                            if (partition != null) {
                                current_volume.offset = partition.offset;
                            }

                            current_volume.mount_point = block_fs.mount_points[0];
                            Posix.statvfs buf;
                            Posix.statvfs_exec (block_fs.mount_points[0], out buf);
                            current_volume.free = (uint64) buf.f_bfree * (uint64) buf.f_bsize;

                            volumes_list.add (current_volume);
                        // } else {
                        //     current_volume.mount_point = "";
                        }
                    }
                }
            });

            volumes_list.sort (compare_volumes);
        }

        return volumes_list;
    }

    public string size_to_display (uint64 size_to_fmt) {
        return udisks_client.get_size_for_display (size_to_fmt, false, false);
    }

    private int compare_drives (DiskDrive? drive1, DiskDrive? drive2) {
        if (drive1 == null) {
            return (drive2 == null) ? 0 : -1;
        }

        if (drive2 == null) {
            return 1;
        }

        return GLib.strcmp (drive1.device, drive2.device);
    }

    private int compare_volumes (MonitorVolume? vol1, MonitorVolume? vol2) {
        if (vol1 == null) {
            return (vol2 == null) ? 0 : -1;
        }

        if (vol2 == null) {
            return 1;
        }

        return GLib.strcmp (vol1.device, vol2.device);
    }
}
