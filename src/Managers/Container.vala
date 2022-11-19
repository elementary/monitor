namespace Monitor {
    enum DockerContainerType {
        GROUP,
        CONTAINER
    }

    enum DockerContainerState {
        UNKNOWN,
        PAUSED,
        RUNNING,
        STOPPED,
    }

    class DockerContainer : Object {
        public Container ? api_container { get; construct set; }

        public string id;

        private string _name;
        public string name {
            get { return _name; }
            set {
                _name = format_name (value);
            }
        }
        public string image;
        public DockerContainerType type;
        public DockerContainerState state;

        public string ? config_path;
        public Gee.ArrayList<DockerContainer> ? services;

        private Cgroup cgroup;

        public DockerContainer (string id) {
            this.id = id;
            this.cgroup = new Cgroup (this.id);
            //  this.id = id;
            //  this.type = DockerContainerType.CONTAINER;
            //  this.state = this.get_state (container.state);
        }

        public string format_name (string name) {
            var value = name;

            if (value[0] == '/') {
                value = value.splice (0, 1);
            }

            return value;
        }

        public DockerContainerState get_state (string state) {
            if (state == "running") {
                return DockerContainerState.RUNNING;
            }
            if (state == "paused") {
                return DockerContainerState.PAUSED;
            }
            if (state == "exited") {
                return DockerContainerState.STOPPED;
            }

            return DockerContainerState.UNKNOWN;
        }

        public static bool equal (DockerContainer a, DockerContainer b) {
            return a.id == b.id;
        }

        public uint64 get_memory () {
            return uint64.parse (cgroup.memory_usage_by_bytes) - 0;
        }

        private uint64 get_mem_stat_total_inactive_file () {
            var file = File.new_for_path ("/sys/fs/cgroup/memory/docker/%s/memory.stat".printf (id));

            /* make sure that it exists, not an error if it doesn't */
            if (!file.query_exists ()) {
                warning ("File doesn't exist ???");

                return 0;
            }

            string mem_stat_total_inactive_file = "bruh";


            try {
                var dis = new DataInputStream (file.read ());
                string ? line;
                while ((line = dis.read_line ()) != null) {
                    var splitted_line = line.split (" ");
                    switch (splitted_line[0]) {
                    case "total_inactive_file":
                        mem_stat_total_inactive_file = splitted_line[1];
                        break;
                    default:
                        break;
                    }
                }
                return uint64.parse (mem_stat_total_inactive_file);
            } catch (Error e) {
                warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
                return 0;
            }
        }

        //  private uint64 get_mem_usage_file () {
        //      var file = File.new_for_path ("/sys/fs/cgroup/memory/docker/%s/memory.usage_in_bytes".printf (id));

        //      /* make sure that it exists, not an error if it doesn't */
        //      if (!file.query_exists ()) {
        //          warning ("File doesn't exist ???");
        //          return 0;
        //      }

        //      try {
        //          var dis = new DataInputStream (file.read ());
        //          return uint64.parse (dis.read_line ());
        //      } catch (Error e) {
        //          warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
        //          return 0;
        //      }
        //  }

    }
}
