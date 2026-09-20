[CCode (lower_case_cprefix = "sd_")]
namespace Systemd {
    [Compact, CCode (cname = "sd_journal", cheader_filename = "systemd/sd-journal.h", free_function = "sd_journal_close")]
    public class Journal {
        [CCode (cname = "int", cprefix = "LOG_", lower_case_cprefix = "sd_journal_", cheader_filename = "systemd/sd-journal.h,syslog.h", has_type_id = false)]
        public enum Priority {
            EMERG,
            ALERT,
            CRIT,
            ERR,
            WARNING,
            NOTICE,
            INFO,
            DEBUG;

            [PrintfFormat]
            public int print (string format, ...);
            public int printv (string format, va_list ap);

            [CCode (instance_pos = 1.5)]
            public int stream_fd (string identifier, bool level_prefix);
            [CCode (cname = "_vala_sd_journal_stream")]
            public GLib.FileStream? stream (string identifier, bool level_prefix) {
                int fd = this.stream_fd (identifier, level_prefix);
                return (fd < 0) ? null : GLib.FileStream.fdopen (fd, "w");
            }
        }

        public static int send (string format, ...);
        public static int sendv (Posix.iovector[] iov);
        public static int perror (string message);

        [Flags, CCode (cname = "int", cprefix = "SD_JOURNAL_", has_type_id = false)]
        public enum OpenFlags {
            LOCAL_ONLY,
            RUNTIME_ONLY,
            SYSTEM,
            CURRENT_USER,
            OS_ROOT,
            ALL_NAMESPACES,
            INCLUDE_DEFAULT_NAMESPACE,
            TAKE_DIRECTORY_FD,
            ASSUME_IMMUTABLE
        }
        public static int open (out Systemd.Journal ret, Systemd.Journal.OpenFlags flags);
        public static int open_namespace (out Systemd.Journal ret, string? name_space, Systemd.Journal.OpenFlags flags);
        public static int open_directory (out Systemd.Journal ret, string path, Systemd.Journal.OpenFlags flags);
        public static int open_files (out Systemd.Journal ret, [CCode (array_length = false, array_null_terminated = true)] string[] paths, Systemd.Journal.OpenFlags flags);

        public int previous ();
        public int next ();

        public int previous_skip (uint64 skip);
        public int next_skip (uint64 skip);

        public int get_realtime_usec (out uint64 ret);
        public int get_monotonic_usec (out uint64 ret, out Systemd.Id128 ret_boot_id);

        public int set_data_threshold (size_t sz);
        public int get_data_threshold (out size_t sz);

        public int get_data (string field, [CCode (type = "const void**", array_length_type = "size_t")] out unowned uint8[] data);
        public int enumerate_data ([CCode (type = "const void**", array_length_type = "size_t")] out unowned uint8[] data);
        public void restart_data ();

        public int add_match ([CCode (array_length_type = "size_t")] uint8[] data);
        public int add_disjunction ();
        public int add_conjunction ();
        public void flush_matches ();

        public int seek_head ();
        public int seek_tail ();
        public int seek_monotonic_usec (Systemd.Id128 boot_id, uint64 usec);
        public int seek_realtime_usec (uint64 usec);
        public int seek_cursor (string cursor);

        public int get_cursor (out unowned string cursor);
        public int test_cursor (string cursor);

        public int get_cutoff_realtime_usec (out uint64 from, out uint64 to);
        public int get_cutoff_monotonic_usec (Systemd.Id128 boot_id, out uint64 from, out uint64 to);

        public int get_usage (out uint64 bytes);

        public int query_unique (string field);
        public int enumerate_unique ([CCode (type = "const void**", array_length_type = "size_t")] out unowned uint8[] data);
        public void restart_unique ();

        public int get_fd ();
        public int get_events ();
        public int get_timeout (out uint64 timeout_usec);
        public int process ();
        public int wait (uint64 timeout_usec);
        public int reliable_fd ();

        public int get_catalog (out unowned string text);
        public int get_catalog_for_message_id (Systemd.Id128 id, out unowned string ret);
    }

    [SimpleType, CCode (cname = "sd_id128_t", lower_case_cprefix = "sd_id128_", cheader_filename = "systemd/sd-id128.h", default_value = "SD_ID128_NULL")]
    public struct Id128 {
        public uint8 bytes[16];
        public uint64 qwords[2];

        [CCode (cname = "SD_ID128_NULL")]
        public const Systemd.Id128 NULL;

        [CCode (cname = "sd_id128_randomize")]
        public static int random (out Systemd.Id128 ret);
        [CCode (cname = "sd_id128_get_machine")]
        public static int machine (out Systemd.Id128 ret);
        [CCode (cname = "sd_id128_get_boot")]
        public static int boot (out Systemd.Id128 ret);
        public static int from_string (string s, out Systemd.Id128 ret);

        [CCode (cname = "_vala_sd_id128_to_string")]
        public string to_string () {
            return this.str;
        }

        public static bool equal (Systemd.Id128 a, Systemd.Id128 b);

        public unowned string str {
            [CCode (cname = "SD_ID128_TO_STRING")]
            get;
        }
    }
}
