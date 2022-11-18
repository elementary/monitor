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
        public Container? api_container {get; construct set;}

        public string id;
        public string name;
        public string image;
        public DockerContainerType type;
        public DockerContainerState state;

        public string? config_path;
        public Gee.ArrayList<DockerContainer>? services;

        public DockerContainer.from_docker_api_container (Container container) {
            this.api_container = container;

            this.id = container.id;
            this.name = this.format_name (container.name);
            this.image = container.image;
            this.type = DockerContainerType.CONTAINER;
            this.state = this.get_state (container.state);
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

        public string get_memory() {
            return read_file("/sys/fs/cgroup/memory/docker/%s/memory.stat".printf (id));
        }

        public static string ? read_file (string path) {
            var file = File.new_for_path (path);
    
            /* make sure that it exists, not an error if it doesn't */
            if (!file.query_exists ()) {
                return null;
            }
            var text = new StringBuilder ();
            try {
                var dis = new DataInputStream (file.read ());
    
                // Doing this because of cmdline file.
                // cmdline is a single line file with each arg seperated by a null character ('\0')
                string line = dis.read_upto ("\0", 1, null);
                while (line != null) {
                    text.append (line);
                    text.append (" ");
                    dis.skip (1);
                    line = dis.read_upto ("\0", 1, null);
                }
    
                return text.str;
            } catch (Error e) {
                warning ("Error reading cmdline file '%s': %s\n", file.get_path (), e.message);
                return null;
            }
        }
    }
}
