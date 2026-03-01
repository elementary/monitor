/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.NetworkConnections {

    public static Gee.HashMap<uint64?, ListeningPort?> build_inode_port_map () {
        var map = new Gee.HashMap<uint64?, ListeningPort?> (
            (a) => { return (uint) (a ^ (a >> 32)); },
            (a, b) => { return a == b; }
        );
        parse_proc_net_file ("/proc/net/tcp", "tcp", true, false, map);
        parse_proc_net_file ("/proc/net/tcp6", "tcp6", true, true, map);
        parse_proc_net_file ("/proc/net/udp", "udp", false, false, map);
        parse_proc_net_file ("/proc/net/udp6", "udp6", false, true, map);
        return map;
    }

    // Public for unit testing
    public static void parse_proc_net_file (string path, string protocol, bool is_tcp, bool is_ipv6, Gee.HashMap<uint64?, ListeningPort?> map) {
        var file = File.new_for_path (path);
        if (!file.query_exists ()) {
            return;
        }

        try {
            var stream = file.read ();
            var dis = new DataInputStream (stream);
            string? line;

            line = dis.read_line ();

            while ((line = dis.read_line ()) != null) {
                line = line.strip ();
                if (line.length == 0) {
                    continue;
                }

                var parts = line.split_set (" \t");
                var fields = new Gee.ArrayList<string> ();
                foreach (var part in parts) {
                    if (part.length > 0) {
                        fields.add (part);
                    }
                }

                if (fields.size < 10) {
                    continue;
                }

                var local_address = fields.get (1);
                var rem_address = fields.get (2);
                var state = fields.get (3);
                var inode_str = fields.get (9);

                if (is_tcp && state != "0A") {
                    continue;
                }

                if (!is_tcp) {
                    if (is_ipv6) {
                        if (rem_address != "00000000000000000000000000000000:0000") {
                            continue;
                        }
                    } else {
                        if (rem_address != "00000000:0000") {
                            continue;
                        }
                    }
                }

                var addr_parts = local_address.split (":");
                if (addr_parts.length < 2) {
                    continue;
                }

                var addr_hex = addr_parts[0];
                var port_hex = addr_parts[1];
                uint16 port = parse_hex_port (port_hex);

                string addr;
                if (is_ipv6) {
                    addr = format_ipv6_address (addr_hex);
                } else {
                    addr = format_ipv4_address (addr_hex);
                }

                uint64 inode = uint64.parse (inode_str);
                if (inode == 0) {
                    continue;
                }

                map.set (inode, ListeningPort () {
                    protocol = protocol,
                    port = port,
                    local_address = addr
                });
            }

        } catch (Error e) {
            warning ("Error reading %s: %s", path, e.message);
        }
    }

    public static string format_ipv4_address (string hex) {
        if (hex.length < 8) {
            return "?.?.?.?";
        }

        var b0 = (uint8) ulong.parse (hex.substring (0, 2), 16);
        var b1 = (uint8) ulong.parse (hex.substring (2, 2), 16);
        var b2 = (uint8) ulong.parse (hex.substring (4, 2), 16);
        var b3 = (uint8) ulong.parse (hex.substring (6, 2), 16);
        return "%u.%u.%u.%u".printf (b3, b2, b1, b0);
    }

    // NOTE: /proc/net stores IPv6 addresses as 4 x 32-bit words in host byte order.
    // This implementation assumes little-endian (x86/x64/ARM64), which covers all
    // architectures supported by elementary OS.
    public static string format_ipv6_address (string hex) {
        if (hex.length < 32) {
            return hex;
        }

        var result = new StringBuilder ();
        for (int i = 0; i < 4; i++) {
            var group = hex.substring (i * 8, 8);
            var b0 = (uint8) ulong.parse (group.substring (0, 2), 16);
            var b1 = (uint8) ulong.parse (group.substring (2, 2), 16);
            var b2 = (uint8) ulong.parse (group.substring (4, 2), 16);
            var b3 = (uint8) ulong.parse (group.substring (6, 2), 16);
            if (i > 0) {
                result.append (":");
            }
            result.append ("%02X%02X".printf (b3, b2));
            result.append (":");
            result.append ("%02X%02X".printf (b1, b0));
        }
        return result.str;
    }

    /** Parses a hex port string from /proc/net. Input is assumed to be valid kernel-generated hex. */
    public static uint16 parse_hex_port (string hex) {
        return (uint16) ulong.parse (hex, 16);
    }

    public static string simplify_address (string addr) {
        // IPv4: keep as-is
        if (!addr.contains (":") || addr.length < 16) {
            return addr;
        }

        // IPv6: compress to standard short form (RFC 5952)
        var groups = addr.split (":");
        if (groups.length != 8) {
            return addr;
        }

        // Convert each group to minimal hex (strip leading zeros)
        var trimmed = new string[8];
        for (int i = 0; i < 8; i++) {
            if (groups[i].length == 0) {
                return addr;
            }

            // Validate hex before parsing
            bool valid_hex = true;
            for (int c = 0; c < groups[i].length; c++) {
                unichar ch = groups[i].get_char (groups[i].index_of_nth_char (c));
                if (!ch.isxdigit ()) {
                    valid_hex = false;
                    break;
                }
            }
            if (!valid_hex) {
                return addr;
            }

            uint64 val = ulong.parse (groups[i], 16);
            trimmed[i] = "%x".printf ((uint) val);
        }

        // Find longest run of consecutive "0" groups
        int best_start = -1;
        int best_len = 0;
        int cur_start = -1;
        int cur_len = 0;
        for (int i = 0; i < 8; i++) {
            if (trimmed[i] == "0") {
                if (cur_start == -1) {
                    cur_start = i;
                    cur_len = 1;
                } else {
                    cur_len++;
                }
                if (cur_len > best_len) {
                    best_start = cur_start;
                    best_len = cur_len;
                }
            } else {
                cur_start = -1;
                cur_len = 0;
            }
        }

        // Build compressed string
        if (best_len >= 2) {
            var sb = new StringBuilder ();
            for (int i = 0; i < best_start; i++) {
                if (i > 0) sb.append (":");
                sb.append (trimmed[i]);
            }
            sb.append ("::");
            for (int i = best_start + best_len; i < 8; i++) {
                if (i > best_start + best_len) sb.append (":");
                sb.append (trimmed[i]);
            }
            return sb.str;
        }

        // No compressible run, just join trimmed groups
        return string.joinv (":", trimmed);
    }
}
