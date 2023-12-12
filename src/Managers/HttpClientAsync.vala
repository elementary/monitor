namespace Monitor {
    public errordomain HttpClientError {
        ERROR,
        ERROR_ACCESS,
        ERROR_NO_ENTRY
    }

    public enum HttpClientMethod {
        GET,
        POST,
        DELETE,
    }

    public class HttpClient : Object {
        public bool verbose = false;
        public string ? unix_socket_path { get; set; }
        public string ? base_url;

        public async HttpClientResponse r_get (string url) throws HttpClientError {
            return yield this.request (HttpClientMethod.GET, url, new HttpClientResponse ());

        }

        public async HttpClientResponse r_post (string url) throws HttpClientError {
            return yield this.request (HttpClientMethod.POST, url, new HttpClientResponse ());

        }

        public async HttpClientResponse r_delete (string url) throws HttpClientError {
            return yield this.request (HttpClientMethod.DELETE, url, new HttpClientResponse ());

        }

        public async HttpClientResponse request (HttpClientMethod method, string url, HttpClientResponse response) throws HttpClientError {
            var curl = new Curl.EasyHandle ();

            Curl.Code r;

            r = curl.setopt (Curl.Option.VERBOSE, this.verbose ? 1 : 0);
            assert_true (r == Curl.Code.OK);
            r = curl.setopt (Curl.Option.URL, (this.base_url ?? "") + url);
            assert_true (r == Curl.Code.OK);
            r = curl.setopt (Curl.Option.UNIX_SOCKET_PATH, this.unix_socket_path);
            assert_true (r == Curl.Code.OK);
            r = curl.setopt (Curl.Option.CUSTOMREQUEST, this.get_request_method (method));
            assert_true (r == Curl.Code.OK);
            r = curl.setopt (Curl.Option.WRITEDATA, (void *) response.memory_stream);
            assert_true (r == Curl.Code.OK);
            r = curl.setopt (Curl.Option.WRITEFUNCTION, HttpClientResponse.read_body_data);
            assert_true (r == Curl.Code.OK);

            //  debug ("call api method: %s - %s", this.get_request_method (method), url);

            yield this.perform (curl);

            long curl_errno = -1;

            r = curl.getinfo (Curl.Info.OS_ERRNO, &curl_errno);
            assert_true (r == Curl.Code.OK);

            if (curl_errno == Posix.ENOENT) {
                throw new HttpClientError.ERROR_NO_ENTRY (strerror ((int) curl_errno));
            } else if (curl_errno == Posix.EACCES) {
                throw new HttpClientError.ERROR_ACCESS (strerror ((int) curl_errno));
            } else if (curl_errno > 0) {
                throw new HttpClientError.ERROR ("Unknown error");
            }

            if (r == Curl.Code.OK) {
                curl.getinfo (Curl.Info.RESPONSE_CODE, &response.code);

                return response;
            }

            throw new HttpClientError.ERROR (Curl.Global.strerror (r));
        }

        public string get_request_method (HttpClientMethod method) {
            var result = "";

            switch (method) {
            case HttpClientMethod.GET:
                result = "GET";
                break;

            case HttpClientMethod.POST:
                result = "POST";
                break;

            case HttpClientMethod.DELETE:
                result = "DELETE";
                break;
            }

            return result;
        }

        private async Curl.Code perform (Curl.EasyHandle curl) throws HttpClientError {
            string ? err_msg = null;
            var r = Curl.Code.OK;

            var task = new Task (this, null, (obj, cl_task) => {
                try {
                    r = (Curl.Code)cl_task.propagate_int ();
                } catch (Error error) {
                    err_msg = error.message;
                } finally {
                    this.perform.callback ();
                }
            });

            task.set_task_data (curl, null);
            task.run_in_thread ((task, http_client, curl, cancellable) => {
                unowned var cl_curl = (Curl.EasyHandle)curl;

                var cl_r = cl_curl.perform ();
                task.return_int (cl_r);
            });

            yield;

            if (err_msg != null) {
                throw new HttpClientError.ERROR (@"Curl perform error: $err_msg");
            }

            return r;
        }

    }

    public class HttpClientResponse : Object {
        public int code;
        public MemoryInputStream memory_stream { get; construct set; }
        public DataInputStream body_data_stream { get; construct set; }

        public HttpClientResponse () {
            this.code = 0;
            this.memory_stream = new MemoryInputStream ();
            this.body_data_stream = new DataInputStream (this.memory_stream);
        }

        public static size_t read_body_data (void * buf, size_t size, size_t nmemb, void * data) {
            size_t real_size = size * nmemb;
            uint8[] buffer = new uint8[real_size];
            var response_memory_stream = (MemoryInputStream) data;

            Posix.memcpy ((void *) buffer, buf, real_size);
            response_memory_stream.add_data (buffer);

            // debug ("http client bytes read: %d", (int)real_size);

            return real_size;
        }

    }
}
