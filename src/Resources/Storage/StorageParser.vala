class Monitor.StorageParser : Object{
    private const string BLOCKS_PATH = "/sys/block";

    construct {
        //  detect_blocks ();
    }

    public void detect_blocks (DiskDrive drive) {
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

}