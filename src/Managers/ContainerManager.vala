namespace Monitor {
    public errordomain ApiClientError {
        ERROR,
        ERROR_JSON,
        ERROR_ACCESS,
        ERROR_NO_ENTRY,
    }

    //  struct Container {
    //      public string id;
    //      public string name;
    //      public string image;
    //      public string state;
    //      public string ? label_project;
    //      public string ? label_service;
    //      public string ? label_config;
    //      public string ? label_workdir;
    //  }

    //  struct ContainerInspectInfo {
    //      public string name;
    //      public string image;
    //      public string status;
    //      public string[] ? binds;
    //      public string[] ? envs;
    //      public string[] ? ports;
    //  }

    //  struct DockerVersionInfo {
    //      public string version;
    //      public string api_version;
    //  }

    public class ContainerManager : Object {
        private static GLib.Once<ContainerManager> instance;
        public static unowned ContainerManager get_default () {
            return instance.once (() => { return new ContainerManager (); });
        }

        public HttpClient http_client;

        private Gee.Map<string, DockerContainer> container_list = new Gee.HashMap<string, DockerContainer> ();

        public signal void container_added (DockerContainer container);
        public signal void container_removed (string id);
        public signal void updated ();

        public ContainerManager () {
            this.http_client = new HttpClient ();
            this.http_client.verbose = false;
            this.http_client.base_url = "http://localhost/v1.41";
            this.http_client.unix_socket_path = "/run/docker.sock";

            this.update_containers.begin ();

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

        public DockerContainer ? get_container (string id) {
            // if (!container_list.has_key (id)) return;
            return container_list[id];
        }

        public Gee.Map<string, DockerContainer> get_container_list () {
            return container_list.read_only_view;
        }

        private bool add_container (Json.Object json_container) {
            if (!container_list.has_key (json_container.get_string_member ("Id"))) {

                var container = new DockerContainer (json_container.get_string_member ("Id"), ref this.http_client) {
                    image = json_container.get_string_member ("Image"),
                    state = json_container.get_string_member ("State"),
                };

                var name_array = json_container.get_array_member ("Names");
                foreach (var name_node in name_array.get_elements ()) {
                    container.name = container.format_name (name_node.get_string ());
                    assert_nonnull (container.name);
                    break;
                }

                var labels_object = json_container.get_object_member ("Labels");
                assert_nonnull (labels_object);

                if (labels_object.has_member ("com.docker.compose.project")) {
                container.compose_project = labels_object.get_string_member ("com.docker.compose.project");
                }
                if (labels_object.has_member ("com.docker.compose.service")) {
                container.compose_service = labels_object.get_string_member ("com.docker.compose.service");
                }
                // if (labels_object.has_member ("com.docker.compose.project.config_files")) {
                // container.label_config = labels_object.get_string_member ("com.docker.compose.project.config_files");
                // }
                // if (labels_object.has_member ("com.docker.compose.project.working_dir")) {
                // container.label_workdir = labels_object.get_string_member ("com.docker.compose.project.working_dir");
                // }

                container_list.set (container.id, container);
                this.container_added (container);
                return true;
            } else {
                return false;
            }
        }

        private void remove_container (DockerContainer container) {
            debug ("removing container: %s", container.name);
            var id = container.id;
            if (container_list.has_key (id)) {
                container_list.unset (id);
                this.container_removed (id);
            }
        }

        public async void update_containers () throws ApiClientError {
            try {
                var resp = yield this.http_client.r_get ("/containers/json?all=true");

                //
                if (resp.code == 400) {
                    throw new ApiClientError.ERROR ("Bad parameter");
                }
                if (resp.code == 500) {
                    throw new ApiClientError.ERROR ("Server error");
                }

                var json = "";
                string ? line = null;

                while ((line = resp.body_data_stream.read_line_utf8 ()) != null) {
                    json += line;
                }

                var root_node = parse_json (json);
                var root_array = root_node.get_array ();
                assert_nonnull (root_array);

                foreach (var container_node in root_array.get_elements ()) {
                    var container_object = container_node.get_object ();
                    assert_nonnull (container_object);

                    this.add_container (container_object);


                }
                var remove_me = new Gee.HashSet<DockerContainer> ();
                foreach (var container in this.container_list.values) {
                    //  debug ("CM updating %s", container.name);
                    if (!container.exists) {
                        remove_me.add (container);
                        continue;
                    }
                    container.update ();
                }

                foreach (var container in remove_me) {
                    debug (container.name);
                    remove_container (container);
                }
                /* emit the updated signal so that subscribers can update */

                updated ();

            } catch (HttpClientError error) {
                if (error is HttpClientError.ERROR_NO_ENTRY) {
                    throw new ApiClientError.ERROR_NO_ENTRY (error.message);
                } else if (error is HttpClientError.ERROR_ACCESS) {
                    throw new ApiClientError.ERROR_ACCESS (error.message);
                } else {
                    throw new ApiClientError.ERROR (error.message);
                }
            } catch (IOError error) {
                throw new ApiClientError.ERROR (error.message);
            }
        }

        // public async ContainerInspectInfo inspect_container (DockerContainer container) throws ApiClientError {
        // try {
        // var container_info = ContainerInspectInfo ();
        // var resp = yield this.http_client.r_get (@"/containers/$(container.id)/json");

        // if (resp.code == 404) {
        // throw new ApiClientError.ERROR ("No such container");
        // }
        // if (resp.code == 500) {
        // throw new ApiClientError.ERROR ("Server error");
        // }

        ////
        // if (resp.code == 404) {
        // throw new ApiClientError.ERROR ("No such container");
        // }
        // if (resp.code == 500) {
        // throw new ApiClientError.ERROR ("Server error");
        // }

        ////
        // var json = yield resp.body_data_stream.read_line_utf8_async ();

        // assert_nonnull (json);

        // var root_node = parse_json (json);
        // var root_object = root_node.get_object ();
        // assert_nonnull (root_object);

        ////
        // container_info.name = root_object.get_string_member ("Name");

        ////
        // var state_object = root_object.get_object_member ("State");
        // assert_nonnull (state_object);

        // container_info.status = state_object.get_string_member ("Status");

        ////
        // var config_object = root_object.get_object_member ("Config");
        // assert_nonnull (config_object);

        // container_info.image = config_object.get_string_member ("Image");

        ////
        // var env_array = config_object.get_array_member ("Env");

        // if (env_array != null && env_array.get_length () > 0) {
        // container_info.envs = new string[0];

        // foreach (var env_node in env_array.get_elements ()) {
        // container_info.envs += env_node.get_string () ?? _("Unknown");
        // }
        // }

        ////
        // var host_config_object = root_object.get_object_member ("HostConfig");

        // if (host_config_object != null) {
        // var binds_array = host_config_object.get_array_member ("Binds");

        // if (binds_array != null && binds_array.get_length () > 0) {
        // container_info.binds = new string[0];

        // foreach (var bind_node in binds_array.get_elements ()) {
        // container_info.binds += bind_node.get_string () ?? _("Unknown");
        // }
        // }
        // }

        ////
        // var port_bindings_object = host_config_object.get_object_member ("PortBindings");

        // if (port_bindings_object != null) {
        // port_bindings_object.foreach_member ((obj, key, port_binding_node) => {
        // var port_binding_array = port_binding_node.get_array ();

        // if (port_binding_array != null && port_binding_array.get_length () > 0) {
        // container_info.ports = new string[0];

        // foreach (var port_node in port_binding_array.get_elements ()) {
        // var port_object = port_node.get_object ();
        // assert_nonnull (port_object);

        //// *with_default () works only with > 1.6.0 of json-glib
        //// var ip = port_object.get_string_member_with_default ("HostIp", "");
        //// var port = port_object.get_string_member_with_default ("HostPort", "-");
        // var ip = port_object.get_string_member ("HostIp");
        // var port = port_object.get_string_member ("HostPort");
        // container_info.ports += key + (ip.length > 0 ? @"$ip:" : ":") + port;
        // }
        // }
        // });
        // }

        // return container_info;
        // } catch (HttpClientError error) {
        // throw new ApiClientError.ERROR (error.message);
        // } catch (IOError error) {
        // throw new ApiClientError.ERROR (error.message);
        // }
        // }

        // public async DockerVersionInfo version () throws ApiClientError {
        // try {
        // var version = DockerVersionInfo ();
        // var resp = yield this.http_client.r_get ("/version");

        ////
        // var json = yield resp.body_data_stream.read_line_utf8_async ();

        // assert_nonnull (json);

        // var root_node = parse_json (json);
        // var root_object = root_node.get_object ();
        // assert_nonnull (root_object);

        //// *with_default () works only with > 1.6.0 of json-glib
        //// version.version = root_object.get_string_member_with_default ("Version", "-");
        //// version.api_version = root_object.get_string_member_with_default ("ApiVersion", "-");
        // version.version = root_object.get_string_member ("Version");
        // version.api_version = root_object.get_string_member ("ApiVersion");
        // return version;
        // } catch (HttpClientError error) {
        // throw new ApiClientError.ERROR (error.message);
        // } catch (IOError error) {
        // throw new ApiClientError.ERROR (error.message);
        // }
        // }

        public async void ping () throws ApiClientError {
            try {
                this.http_client.r_get ("/_ping");

            } catch (HttpClientError error) {
                if (error is HttpClientError.ERROR_NO_ENTRY) {
                    throw new ApiClientError.ERROR_NO_ENTRY (error.message);
                } else {
                    throw new ApiClientError.ERROR (error.message);
                }
            }
        }

    }
}
