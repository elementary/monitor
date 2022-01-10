public class Monitor.Core : GLib.Object {
    private float last_total;
        private float last_used;

        private float _percentage_used;

        private string cache_path {
            owned get {
                return "/sys/devices/system/cpu/cpu%d/cache".printf (number);
            }
        }

        public Gee.HashMap<string, CPUCache> caches { public get; private set; }


        public int number { get; set; }
        public float percentage_used {
            get {
                return _percentage_used;
            }
        }

        public Core (int number) {
            Object (number: number);
            last_used = 0;
            last_total = 0;

            caches = new Gee.HashMap<string, CPUCache> ();
            get_cache (number);

            //  foreach (var item in caches.keys) {
            //      debug ("%d, %s", number, item);
            //  }

        }

        public void update () {
            GTop.Cpu cpu;
            GTop.get_cpu (out cpu);

            var used = cpu.xcpu_user[number] + cpu.xcpu_nice[number] + cpu.xcpu_sys[number];

            var difference_used = (float) used - last_used;
            var difference_total = (float) cpu.xcpu_total[number] - last_total;
            var pre_percentage = difference_used.abs () / difference_total.abs (); // calculate the pre percentage

            _percentage_used = pre_percentage * 100;

            last_used = (float) used;
            last_total = (float) cpu.xcpu_total[number];

            // debug("Core %d: %f%%", number, _percentage_used);
        }

        private void get_cache (int core_id) {

            try {

                Dir cache_dir = Dir.open (cache_path, 0);

                string ? cache_dir_content = null;
                while ((cache_dir_content = cache_dir.read_name ()) != null) {

                    if (cache_dir_content == "uevent") continue;

                    string ? cache_indexx_prop = null;
                    Dir cache_indexx = Dir.open (Path.build_filename (cache_path, cache_dir_content));

                    string level, type;
                    string path_level = Path.build_filename (cache_path, cache_dir_content, "level");
                    string path_type = Path.build_filename (cache_path, cache_dir_content, "type");
                    FileUtils.get_contents (path_level, out level);
                    FileUtils.get_contents (path_type, out type);

                    var cpu_cache = new CPUCache ();
                    while (( cache_indexx_prop = cache_indexx.read_name ()) != null) {

                        if (cache_indexx_prop == "uevent") continue;

                        string temp_content;
                        FileUtils.get_contents (Path.build_filename (cache_path, cache_dir_content, cache_indexx_prop), out temp_content);

                        switch (cache_indexx_prop) {
                            case "size":
                                cpu_cache.size = temp_content.strip ();
                                break;
                            case "allocation_policy":
                                cpu_cache.allocation_policy = temp_content.strip ();
                                break;
                            case "attributes":
                                cpu_cache.attributes = temp_content.strip ();
                                break;
                            case "coherency_line_size":
                                cpu_cache.coherency_line_size = temp_content.strip ();
                                break;
                            case "level":
                                cpu_cache.level = temp_content.strip ();
                                break;
                            case "number_of_sets":
                                cpu_cache.number_of_sets = temp_content.strip ();
                                break;
                            case "physical_line_partition":
                                cpu_cache.physical_line_partition = temp_content.strip ();
                                break;
                            case "shared_cpu_list":
                                cpu_cache.shared_cpu_list = temp_content.strip ();
                                break;
                            case "type":
                                cpu_cache.type = temp_content.strip ();
                                break;
                            case "shared_cpu_map":
                                cpu_cache.shared_cpu_map = temp_content.strip ();
                                break;
                            case "ways_of_associativity":
                                cpu_cache.ways_of_associativity = temp_content.strip ();
                                break;
                            case "write_policy":
                                cpu_cache.write_policy = temp_content.strip ();
                                break;
                            default:
                                break;
                            }
                    }
                    // making an id from level and type, should be unique
                    if (level.strip () == "1" && (type.strip () == "Data" || type.strip () == "Instruction")) {
                        caches.set ("L1" + type.strip (), cpu_cache);
                        continue;

                    } else {
                        caches.set ("L" + level.strip (), cpu_cache);
                    }

                }
            } catch (FileError e) {
                warning ("Error while parsing cpu cache: %s", e.message);
            }


            //  string cur_content;
            //  try {
            //      FileUtils.get_contents (cache_path, out cur_content);
            //  } catch (Error e) {
            //      warning (e.message);
            //      cur_content = "0";
            //  }
        }

}
