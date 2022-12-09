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

        public int64 mem_used { get; private set; }
        public int64 mem_available { get; private set; }

        public uint mem_percentage {
            get {
                return (uint) (Math.round ((mem_used / mem_available) * 100.0));
            }
        }

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

        public HttpClient http_client;

        private Cgroup cgroup;

        public DockerContainer (string id, ref HttpClient http_client) {
            this.id = id;
            this.cgroup = new Cgroup (this.id);
            this.http_client = http_client;
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
            return uint64.parse (cgroup.memory_usage_by_bytes) - uint64.parse (cgroup.memory_stat_total_inactive_file);
        }

        private static Json.Node parse_json (string data) throws ApiClientError {
            try {
                var parser = new Json.Parser ();
                parser.load_from_data (data);

                var node = parser.get_root ();

                if (node == null) {
                    throw new ApiClientError.ERROR_JSON ("Cannot parse json from: %s", data);
                }

                return node;
            } catch (Error error) {
                throw new ApiClientError.ERROR_JSON (error.message);
            }
        }

        public async void stats () throws ApiClientError {
            try {
                debug (">>______________");

                var resp = yield this.http_client.r_get (@"/containers/$(this.id)/stats?stream=false");
                var json = yield resp.body_data_stream.read_line_utf8_async ();
                assert_nonnull (json);

                var root_node = parse_json (json);
                var root_object = root_node.get_object ();
                //  assert_nonnull (root_object);

                debug ("______________<<");
                debug (root_object.get_string_member ("read"));

                var json_memory_stats = root_object.get_object_member ("memory_stats");
                var json_memory_stats_stats = json_memory_stats.get_object_member ("stats");


                this.mem_used = json_memory_stats.get_int_member ("usage") - json_memory_stats_stats.get_int_member ("cache");
                debug ("************** %lld", mem_used);

            } catch (HttpClientError error) {
                throw new ApiClientError.ERROR (error.message);
            } catch (IOError error) {
                throw new ApiClientError.ERROR (error.message);
            }
        }

        //  private uint64 get_mem_stat_total_inactive_file () {
        //      var file = File.new_for_path ("/sys/fs/cgroup/memory/docker/%s/memory.stat".printf (id));

        //      /* make sure that it exists, not an error if it doesn't */
        //      if (!file.query_exists ()) {
        //          warning ("File doesn't exist ???");

        //          return 0;
        //      }

        //      string mem_stat_total_inactive_file = "bruh";


        //      try {
        //          var dis = new DataInputStream (file.read ());
        //          string ? line;
        //          while ((line = dis.read_line ()) != null) {
        //              var splitted_line = line.split (" ");
        //              switch (splitted_line[0]) {
        //              case "total_inactive_file":
        //                  mem_stat_total_inactive_file = splitted_line[1];
        //                  break;
        //              default:
        //                  break;
        //              }
        //          }
        //          return uint64.parse (mem_stat_total_inactive_file);
        //      } catch (Error e) {
        //          warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
        //          return 0;
        //      }
        //  }

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
