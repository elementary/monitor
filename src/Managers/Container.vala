namespace Monitor {
    enum DockerContainerType {
        GROUP,
        CONTAINER
    }

    public enum DockerContainerState {
        UNKNOWN,
        PAUSED,
        RUNNING,
        STOPPED,
    }

    public class DockerContainer : Object {

        public int64 mem_used { get; private set; }
        public int64 mem_available { get; private set; }

        public double mem_percentage {
            get {
                if (this.mem_used == 0) return 0;
                return (((double) mem_used / (double) mem_available) * 1000.0);
            }
        }

        public double cpu_percentage { get; private set; }

        const int HISTORY_BUFFER_SIZE = 30;
        public Gee.ArrayList<double ? > cpu_percentage_history = new Gee.ArrayList<double ? > ();
        public Gee.ArrayList<double ? > mem_percentage_history = new Gee.ArrayList<double ? > ();


        // public Container ? api_container { get; construct set; }

        public string id;

        private string _name;
        public string name {
            get {
                return _name;
            }
            set {
                _name = format_name (value);
            }
        }
        public string image;
        // public DockerContainerType type;
        // public DockerContainerState state;

        public string ? config_path;
        public Gee.ArrayList<DockerContainer> ? services;

        public HttpClient http_client;

        private Cgroup cgroup;

        public DockerContainer (string id, ref HttpClient http_client) {
            this.id = id;
            this.cgroup = new Cgroup (this.id);
            this.http_client = http_client;
            // this.id = id;
            // this.type = DockerContainerType.CONTAINER;
            // this.state = this.get_state (container.state);
            cpu_percentage = 0;
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
                var resp = yield this.http_client.r_get (@"/containers/$(this.id)/stats?stream=false");

                if (resp.code == 400) {
                    throw new ApiClientError.ERROR ("Bad parameter");
                }
                if (resp.code == 500) {
                    throw new ApiClientError.ERROR ("Server error");
                }

                var json = yield resp.body_data_stream.read_line_utf8_async ();

                // assert_nonnull (json);

                var root_node = parse_json (json);
                var root_object = root_node.get_object ();
                // assert_nonnull (root_object);

                var json_memory_stats = root_object.get_object_member ("memory_stats");
                assert_nonnull (json_memory_stats);

                // Newer version of json library has default values option
                if (json_memory_stats.has_member ("stats")) {
                    var json_memory_stats_stats = json_memory_stats.get_object_member ("stats");
                    this.mem_used = json_memory_stats.get_int_member ("usage") - json_memory_stats_stats.get_int_member ("cache");
                    this.mem_available = json_memory_stats.get_int_member ("limit");
                } else {
                    this.mem_used = 0;
                    this.mem_available = 0;
                }

                var json_cpu_stats = root_object.get_object_member ("cpu_stats");
                assert_nonnull (json_cpu_stats);
                var json_precpu_stats = root_object.get_object_member ("precpu_stats");

                var json_cpu_usage = json_cpu_stats.get_object_member ("cpu_usage");
                int64 total_usage = json_cpu_usage.get_int_member ("total_usage");

                var json_precpu_usage = json_precpu_stats.get_object_member ("cpu_usage");
                int64 pretotal_usage = json_precpu_usage.get_int_member ("total_usage");

                int64 cpu_delta = total_usage - pretotal_usage;

                if (json_cpu_stats.has_member ("system_cpu_usage")) {
                int64 system_cpu_usage = json_cpu_stats.get_int_member ("system_cpu_usage");
                int64 presystem_cpu_usage = json_precpu_stats.get_int_member ("system_cpu_usage");

                int64 system_cpu_delta = system_cpu_usage - presystem_cpu_usage;
                int64 number_cpus = json_cpu_stats.get_int_member ("online_cpus");

                //  debug("%lld, %lld", total_usage, pretotal_usage);

                cpu_percentage = ((double)cpu_delta / (double)system_cpu_delta) * (double)number_cpus * 1000.0;
                } else {
                    cpu_percentage = 1;
                }

                // Making RAM history
                if (mem_percentage_history.size == HISTORY_BUFFER_SIZE) {
                    mem_percentage_history.remove_at (0);
                }
                mem_percentage_history.add (mem_percentage);

                // Making RAM history
                if (cpu_percentage_history.size == HISTORY_BUFFER_SIZE) {
                    cpu_percentage_history.remove_at (0);
                }
                cpu_percentage_history.add (cpu_percentage);


            } catch (HttpClientError error) {
                throw new ApiClientError.ERROR (error.message);
            } catch (IOError error) {
                throw new ApiClientError.ERROR (error.message);
            }
        }

        // private uint64 get_mem_stat_total_inactive_file () {
        // var file = File.new_for_path ("/sys/fs/cgroup/memory/docker/%s/memory.stat".printf (id));

        ///* make sure that it exists, not an error if it doesn't */
        // if (!file.query_exists ()) {
        // warning ("File doesn't exist ???");

        // return 0;
        // }

        // string mem_stat_total_inactive_file = "bruh";


        // try {
        // var dis = new DataInputStream (file.read ());
        // string ? line;
        // while ((line = dis.read_line ()) != null) {
        // var splitted_line = line.split (" ");
        // switch (splitted_line[0]) {
        // case "total_inactive_file":
        // mem_stat_total_inactive_file = splitted_line[1];
        // break;
        // default:
        // break;
        // }
        // }
        // return uint64.parse (mem_stat_total_inactive_file);
        // } catch (Error e) {
        // warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
        // return 0;
        // }
        // }

        // private uint64 get_mem_usage_file () {
        // var file = File.new_for_path ("/sys/fs/cgroup/memory/docker/%s/memory.usage_in_bytes".printf (id));

        ///* make sure that it exists, not an error if it doesn't */
        // if (!file.query_exists ()) {
        // warning ("File doesn't exist ???");
        // return 0;
        // }

        // try {
        // var dis = new DataInputStream (file.read ());
        // return uint64.parse (dis.read_line ());
        // } catch (Error e) {
        // warning ("Error reading file '%s': %s\n", file.get_path (), e.message);
        // return 0;
        // }
        // }

    }
}
