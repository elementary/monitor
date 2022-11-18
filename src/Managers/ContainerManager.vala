namespace Monitor {
    errordomain ApiClientError {
        ERROR,
        ERROR_JSON,
        ERROR_ACCESS,
        ERROR_NO_ENTRY,
    }

    struct Container {
        public string id;
        public string name;
        public string image;
        public string state;
        public string? label_project;
        public string? label_service;
        public string? label_config;
        public string? label_workdir;
    }

    struct ContainerInspectInfo {
        public string name;
        public string image;
        public string status;
        public string[]? binds;
        public string[]? envs;
        public string[]? ports;
    }

    struct DockerVersionInfo {
        public string version;
        public string api_version;
    }

    class ContainerManager : Object {
        public HttpClient http_client;

        public ContainerManager () {
            this.http_client = new HttpClient ();
            this.http_client.verbose = false;
            this.http_client.base_url = "http://localhost/v1.41";
            this.http_client.unix_socket_path = "/run/docker.sock";
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

        public async Gee.ArrayList<DockerContainer> list_containers () throws ApiClientError {
            try {
                Gee.ArrayList<DockerContainer> containers = new Gee.ArrayList<DockerContainer> ();

                var resp = yield this.http_client.r_get ("/containers/json?all=true");

                //
                if (resp.code == 400) {
                    throw new ApiClientError.ERROR ("Bad parameter");
                }
                if (resp.code == 500) {
                    throw new ApiClientError.ERROR ("Server error");
                }

                //
                var json = "";
                string? line = null;

                while ((line = yield resp.body_data_stream.read_line_utf8_async ()) != null) {
                    json += line;
                }

                //
                var root_node = parse_json (json);
                var root_array = root_node.get_array ();
                assert_nonnull (root_array);

                foreach (var container_node in root_array.get_elements ()) {
                    var container = new DockerContainer ();
                    var container_object = container_node.get_object ();
                    assert_nonnull (container_object);

                    //
                    container.id = container_object.get_string_member ("Id");
                    container.image = container_object.get_string_member ("Image");
                    container.state = container.get_state (container_object.get_string_member ("State"));

                    //
                    var name_array = container_object.get_array_member ("Names");

                    foreach (var name_node in name_array.get_elements ()) {
                        container.name = container.format_name (name_node.get_string ());
                        assert_nonnull (container.name);
                        break;
                    }

                    //
                    var labels_object = container_object.get_object_member ("Labels");
                    assert_nonnull (labels_object);

                    //  if (labels_object.has_member ("com.docker.compose.project")) {
                    //      container.label_project = container.labels_object.get_string_member ("com.docker.compose.project");
                    //  }
                    //  if (labels_object.has_member ("com.docker.compose.service")) {
                    //      container.label_service = labels_object.get_string_member ("com.docker.compose.service");
                    //  }
                    //  if (labels_object.has_member ("com.docker.compose.project.config_files")) {
                    //      container.label_config = labels_object.get_string_member ("com.docker.compose.project.config_files");
                    //  }
                    //  if (labels_object.has_member ("com.docker.compose.project.working_dir")) {
                    //      container.label_workdir = labels_object.get_string_member ("com.docker.compose.project.working_dir");
                    //  }

                    //
                    containers.add (container);
                }

                return containers;
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




        public async ContainerInspectInfo inspect_container (Container container) throws ApiClientError {
            try {
                var container_info = ContainerInspectInfo ();
                var resp = yield this.http_client.r_get (@"/containers/$(container.id)/json");

                //
                if (resp.code == 404) {
                    throw new ApiClientError.ERROR ("No such container");
                }
                if (resp.code == 500) {
                    throw new ApiClientError.ERROR ("Server error");
                }

                //
                var json = yield resp.body_data_stream.read_line_utf8_async ();
                assert_nonnull (json);

                var root_node = parse_json (json);
                var root_object = root_node.get_object ();
                assert_nonnull (root_object);

                //
                container_info.name = root_object.get_string_member("Name");

                //
                var state_object = root_object.get_object_member ("State");
                assert_nonnull (state_object);

                container_info.status = state_object.get_string_member("Status");

                //
                var config_object = root_object.get_object_member ("Config");
                assert_nonnull (config_object);

                container_info.image = config_object.get_string_member ("Image");

                //
                var env_array = config_object.get_array_member ("Env");

                if (env_array != null && env_array.get_length () > 0) {
                    container_info.envs = new string[0];

                    foreach (var env_node in env_array.get_elements ()) {
                        container_info.envs += env_node.get_string () ?? _ ("Unknown");
                    }
                }

                //
                var host_config_object = root_object.get_object_member ("HostConfig");

                if (host_config_object != null) {
                    var binds_array = host_config_object.get_array_member ("Binds");

                    if (binds_array != null && binds_array.get_length () > 0) {
                        container_info.binds = new string[0];

                        foreach (var bind_node in binds_array.get_elements ()) {
                            container_info.binds += bind_node.get_string () ?? _ ("Unknown");
                        }
                    }
                }

                //
                var port_bindings_object = host_config_object.get_object_member ("PortBindings");

                if (port_bindings_object != null) {
                    port_bindings_object.foreach_member ((obj, key, port_binding_node) => {
                        var port_binding_array = port_binding_node.get_array ();

                        if (port_binding_array != null && port_binding_array.get_length () > 0) {
                            container_info.ports = new string[0];

                            foreach (var port_node in port_binding_array.get_elements ()) {
                                var port_object = port_node.get_object ();
                                assert_nonnull (port_object);
                                
                                // *with_default () works only with > 1.6.0 of json-glib
                                //  var ip = port_object.get_string_member_with_default ("HostIp", "");
                                //  var port = port_object.get_string_member_with_default ("HostPort", "-");
                                var ip = port_object.get_string_member ("HostIp");
                                var port = port_object.get_string_member ("HostPort");
                                container_info.ports += key + (ip.length > 0 ? @"$ip:" : ":") + port;
                            }
                        }
                    });
                }

                return container_info;
            } catch (HttpClientError error) {
                throw new ApiClientError.ERROR (error.message);
            } catch (IOError error) {
                throw new ApiClientError.ERROR (error.message);
            }
        }

        public async DockerVersionInfo version () throws ApiClientError {
            try {
                var version = DockerVersionInfo ();
                var resp = yield this.http_client.r_get ("/version");

                //
                var json = yield resp.body_data_stream.read_line_utf8_async ();
                assert_nonnull (json);

                var root_node = parse_json (json);
                var root_object = root_node.get_object ();
                assert_nonnull (root_object);

                // *with_default () works only with > 1.6.0 of json-glib
                //  version.version = root_object.get_string_member_with_default ("Version", "-");
                //  version.api_version = root_object.get_string_member_with_default ("ApiVersion", "-");
                version.version = root_object.get_string_member ("Version");
                version.api_version = root_object.get_string_member ("ApiVersion");
                return version;
            } catch (HttpClientError error) {
                throw new ApiClientError.ERROR (error.message);
            } catch (IOError error) {
                throw new ApiClientError.ERROR (error.message);
            }
        }

        public async void ping () throws ApiClientError {
            try {
                yield this.http_client.r_get ("/_ping");
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
