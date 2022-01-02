class Monitor.StorageParser : Object{
    private const string BLOCKS_PATH = "/sys/block";

    construct {
        //  detect_blocks ();
    }

    public void detect_blocks (Disk drive) {
        try {
            Dir blocks_dir = Dir.open (BLOCKS_PATH, 0);

            string ? block = null;

            while ((block = blocks_dir.read_name ()) != null) {
                if (drive.device.contains (block)) {
                    break;
                }
            }

            string drive_dev = block;
            debug ("Found block device: " + drive_dev);

            string drive_dir_path = Path.build_filename (BLOCKS_PATH, drive_dev);
            Dir drive_dir = Dir.open (drive_dir_path, 0);

            string ? some_file = null;
            while ((some_file = drive_dir.read_name ()) != null) {
                if (some_file.contains (drive_dev)) {
                    debug ("Found block device: " + some_file);
                }
            }

        } catch (FileError e) {
            warning ("%s", e.message);
        }
    }

    public void detect_holders (string path_to_block) {
    //      try {
    //          Dir holders_dir = Dir.open (path_to_block, 0);

    //          string ? holder = null;

    //          while ((holder = holders_dir.read_name ()) != null) {
    //              if (holder.contains ("holders")) {
    //                  break;
    //              }
    //          }

    //          string holders_dir_path = Path.build_filename (path_to_block, holder);
    //          Dir holders_dir = Dir.open (holders_dir_path, 0);

    //          string ? holder_file = null;
    //          while ((holder_file = holders_dir.read_name ()) != null) {
    //              if (holder_file.contains ("holders")) {
    //                  debug ("Found holder: " + holder_file);
    //              }
    //          }

    //      } catch (FileError e) {
    //          warning ("%s", e.message);
        //  }
    }

    public Gee.ArrayList<string?> get_slaves_names (string volume_name) {
        Gee.ArrayList<string?> slaves_names = new Gee.ArrayList<string?> ();

        try {
            Dir slaves_dir = Dir.open (Path.build_filename (BLOCKS_PATH, volume_name, "slaves"), 0);

            string ? slave = null;

            while ((slave = slaves_dir.read_name ()) != null) {
                debug ("Found slave: " + slave);
            }

            //  string slaves_dir_path = Path.build_filename (BLOCKS_PATH, volume_name, slave);
            //  Dir slaves_dir = Dir.open (slaves_dir_path, 0);

            //  string ? slave_file = null;
            //  while ((slave_file = slaves_dir.read_name ()) != null) {
            //      if (slave_file.contains ("slaves")) {
            //          debug ("Found slave: " + slave_file);
            //      }
            //  }

        } catch (FileError e) {
            warning ("%s", e.message);
        }

        return slaves_names;
    }

}