/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

using Monitor;

private string write_tmp_proc_file (string contents, out string tmp_dir) {
    tmp_dir = DirUtils.make_tmp ("monitor-proc-XXXXXX");
    string tmp_path = Path.build_filename (tmp_dir, "proc_net");
    FileUtils.set_contents (tmp_path, contents);
    return tmp_path;
}

private void test_network_connections () {
    Test.add_func ("/Monitor/NetworkConnections#format_ipv4_loopback", () => {
        assert (NetworkConnections.format_ipv4_address ("0100007F") == "127.0.0.1");
    });

    Test.add_func ("/Monitor/NetworkConnections#format_ipv4_zeros", () => {
        assert (NetworkConnections.format_ipv4_address ("00000000") == "0.0.0.0");
    });

    Test.add_func ("/Monitor/NetworkConnections#format_ipv4_private", () => {
        assert (NetworkConnections.format_ipv4_address ("0101A8C0") == "192.168.1.1");
    });

    Test.add_func ("/Monitor/NetworkConnections#parse_port_80", () => {
        assert (NetworkConnections.parse_hex_port ("0050") == 80);
    });

    Test.add_func ("/Monitor/NetworkConnections#parse_port_443", () => {
        assert (NetworkConnections.parse_hex_port ("01BB") == 443);
    });

    Test.add_func ("/Monitor/NetworkConnections#parse_port_8080", () => {
        assert (NetworkConnections.parse_hex_port ("1F90") == 8080);
    });

    Test.add_func ("/Monitor/NetworkConnections#format_ipv6_loopback", () => {
        string result = NetworkConnections.format_ipv6_address ("00000000000000000000000001000000");
        assert (result == "0000:0000:0000:0000:0000:0000:0000:0001");
    });

    Test.add_func ("/Monitor/NetworkConnections#build_map_no_crash", () => {
        var map = NetworkConnections.build_inode_port_map ();
        assert (map != null);
    });

    Test.add_func ("/Monitor/NetworkConnections#tcp_listen_state_filter", () => {
        string header = "  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode\n";
        string contents = header +
            " 0: 0100007F:0050 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0 0 12345 1 0000000000000000 100 0 0 10 0\n" +
            " 1: 0100007F:01BB 0101A8C0:9C40 01 00000000:00000000 00:00000000 00000000 1000 0 67890 1 0000000000000000 100 0 0 10 0\n" +
            " 2: 0100007F:1770 00000000:0000 06 00000000:00000000 00:00000000 00000000 1000 0 24680 1 0000000000000000 100 0 0 10 0\n";
        string tmp_dir;
        string tmp_path = write_tmp_proc_file (contents, out tmp_dir);

        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        NetworkConnections.parse_proc_net_file (tmp_path, "tcp", true, false, map);

        assert (map.size == 1);
        assert (map.has_key ((uint64) 12345));
        assert (!map.has_key ((uint64) 67890));
        assert (!map.has_key ((uint64) 24680));

        FileUtils.remove (tmp_path);
        FileUtils.remove (tmp_dir);
    });

    Test.add_func ("/Monitor/NetworkConnections#udp_remote_filter", () => {
        string header = "  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode\n";
        string contents = header +
            " 0: 00000000:0035 00000000:0000 07 00000000:00000000 00:00000000 00000000 0 0 11111 1 0000000000000000 100 0 0 10 0\n" +
            " 1: 00000000:0035 0101A8C0:1234 07 00000000:00000000 00:00000000 00000000 0 0 22222 1 0000000000000000 100 0 0 10 0\n";
        string tmp_dir;
        string tmp_path = write_tmp_proc_file (contents, out tmp_dir);

        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        NetworkConnections.parse_proc_net_file (tmp_path, "udp", false, false, map);

        assert (map.size == 1);
        assert (map.has_key ((uint64) 11111));
        assert (!map.has_key ((uint64) 22222));

        FileUtils.remove (tmp_path);
        FileUtils.remove (tmp_dir);
    });

    Test.add_func ("/Monitor/NetworkConnections#header_skipped", () => {
        string header = "  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode\n";
        string contents = header +
            " 0: 0100007F:0050 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0 0 33333 1 0000000000000000 100 0 0 10 0\n";
        string tmp_dir;
        string tmp_path = write_tmp_proc_file (contents, out tmp_dir);

        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        NetworkConnections.parse_proc_net_file (tmp_path, "tcp", true, false, map);

        assert (map.size == 1);
        assert (map.has_key ((uint64) 33333));

        FileUtils.remove (tmp_path);
        FileUtils.remove (tmp_dir);
    });

    Test.add_func ("/Monitor/NetworkConnections#empty_file", () => {
        string tmp_dir;
        string tmp_path = write_tmp_proc_file ("", out tmp_dir);

        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        NetworkConnections.parse_proc_net_file (tmp_path, "tcp", true, false, map);

        assert (map.size == 0);

        FileUtils.remove (tmp_path);
        FileUtils.remove (tmp_dir);
    });

    Test.add_func ("/Monitor/NetworkConnections#format_ipv6_known_tcp6", () => {
        // Real tcp6 entry for ::ffff:127.0.0.1 (IPv4-mapped IPv6)
        // The kernel stores IPv6 as 4 x 32-bit words in host byte order (little-endian on x86/ARM64).
        // Network-order value 0x0000FFFF becomes LE bytes FF FF 00 00, printed as FFFF0000.
        // So ::ffff:127.0.0.1 in /proc/net/tcp6 on LE is: 0000000000000000FFFF00000100007F
        string result = NetworkConnections.format_ipv6_address ("0000000000000000FFFF00000100007F");
        assert (result == "0000:0000:0000:0000:0000:FFFF:7F00:0001");
    });

    Test.add_func ("/Monitor/NetworkConnections#full_tcp_line_parse", () => {
        // Full realistic /proc/net/tcp line: nginx listening on 0.0.0.0:80
        string header = "  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode\n";
        string contents = header +
            " 0: 00000000:0050 00000000:0000 0A 00000000:00000000 00:00000000 00000000 0 0 99999 1 0000000000000000 100 0 0 10 0\n";
        string tmp_dir;
        string tmp_path = write_tmp_proc_file (contents, out tmp_dir);

        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        NetworkConnections.parse_proc_net_file (tmp_path, "tcp", true, false, map);

        assert (map.size == 1);
        assert (map.has_key ((uint64) 99999));

        var lp = map.get ((uint64) 99999);
        assert (lp.protocol == "tcp");
        assert (lp.port == 80);
        assert (lp.local_address == "0.0.0.0");

        FileUtils.remove (tmp_path);
        FileUtils.remove (tmp_dir);
    });

    // simplify_address tests

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv4_passthrough", () => {
        assert (NetworkConnections.simplify_address ("192.168.1.1") == "192.168.1.1");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv4_loopback", () => {
        assert (NetworkConnections.simplify_address ("127.0.0.1") == "127.0.0.1");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv6_loopback", () => {
        // ::1
        assert (NetworkConnections.simplify_address ("0000:0000:0000:0000:0000:0000:0000:0001") == "::1");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv6_all_zeros", () => {
        // ::
        assert (NetworkConnections.simplify_address ("0000:0000:0000:0000:0000:0000:0000:0000") == "::");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv6_no_compression", () => {
        // No consecutive zero groups to compress
        assert (NetworkConnections.simplify_address ("2001:0db8:0001:0002:0003:0004:0005:0006") == "2001:db8:1:2:3:4:5:6");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv6_single_zero_no_compress", () => {
        // Single zero group should NOT compress (RFC 5952 requires run >= 2)
        assert (NetworkConnections.simplify_address ("2001:0db8:0000:0001:0002:0003:0004:0005") == "2001:db8:0:1:2:3:4:5");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv6_mapped_v4", () => {
        // IPv4-mapped IPv6: ::ffff:0:7f00:1
        assert (NetworkConnections.simplify_address ("0000:0000:0000:0000:FFFF:0000:7F00:0001") == "::ffff:0:7f00:1");
    });

    Test.add_func ("/Monitor/NetworkConnections#simplify_ipv6_longest_run", () => {
        // Should compress the longest run of zeros
        assert (NetworkConnections.simplify_address ("2001:0000:0000:0000:0000:0db8:0000:0001") == "2001::db8:0:1");
    });

    // Edge case tests: invalid/short input

    Test.add_func ("/Monitor/NetworkConnections#format_ipv4_short_input", () => {
        assert (NetworkConnections.format_ipv4_address ("0100") == "?.?.?.?");
    });

    Test.add_func ("/Monitor/NetworkConnections#format_ipv6_short_input", () => {
        // Short hex should be returned as-is
        assert (NetworkConnections.format_ipv6_address ("0000FFFF") == "0000FFFF");
    });

    // IPv6 UDP6 remote address filter

    Test.add_func ("/Monitor/NetworkConnections#udp6_remote_filter", () => {
        string header = "  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode\n";
        string contents = header +
            " 0: 00000000000000000000000000000000:0035 00000000000000000000000000000000:0000 07 00000000:00000000 00:00000000 00000000 0 0 44444 1 0000000000000000 100 0 0 10 0\n" +
            " 1: 00000000000000000000000000000000:0035 00000000000000000000000001000000:1234 07 00000000:00000000 00:00000000 00000000 0 0 55555 1 0000000000000000 100 0 0 10 0\n";
        string tmp_dir;
        string tmp_path = write_tmp_proc_file (contents, out tmp_dir);

        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        NetworkConnections.parse_proc_net_file (tmp_path, "udp6", false, true, map);

        assert (map.size == 1);
        assert (map.has_key ((uint64) 44444));
        assert (!map.has_key ((uint64) 55555));

        FileUtils.remove (tmp_path);
        FileUtils.remove (tmp_dir);
    });

    // Full end-to-end with corrected IPv4-mapped IPv6

    Test.add_func ("/Monitor/NetworkConnections#simplify_corrected_mapped_v4", () => {
        // The real kernel output for ::ffff:127.0.0.1 on LE produces 0000:0000:0000:0000:0000:FFFF:7F00:0001
        assert (NetworkConnections.simplify_address ("0000:0000:0000:0000:0000:FFFF:7F00:0001") == "::ffff:7f00:1");
    });
}
