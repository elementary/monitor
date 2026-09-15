/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

 public class Monitor.SystemdLogEntry : GLib.Object {
    public string origin { get; construct; }
    public string message { get; construct; }
    public DateTime dt { get; construct; }
    public Systemd.Journal.Priority priority { get; construct; }

    public string relative_time { get; private set; }
    public uint section_start { get; set; }

    public SystemdLogEntry (string origin, string message, DateTime time, Systemd.Journal.Priority priority) {
        Object (
            origin: origin,
            message: message,
            dt: time,
            priority: priority
        );
    }

    construct {
        relative_time = format_time (dt);
    }

    public bool matches (string term) {
        return origin.contains (term) || message.contains (term);
    }

    private static string format_time (DateTime time) {
        var diff = SystemdLogModel.get_stable_now ().difference (time);
        if (diff < TimeSpan.SECOND) {
            return _("Now");
        } else if (diff < TimeSpan.MINUTE) {
            var seconds = diff / TimeSpan.SECOND;
            return dngettext (GETTEXT_PACKAGE, "%ds ago", "%ds ago", (ulong) seconds).printf ((int) seconds);
        } else if (diff < TimeSpan.HOUR) {
            var minutes = diff / TimeSpan.MINUTE;
            var seconds = (diff - minutes * TimeSpan.MINUTE) / TimeSpan.SECOND;

            if (seconds == 0) {
                return dngettext (GETTEXT_PACKAGE, "%dm ago", "%dm ago", (ulong) minutes).printf ((int) minutes);
            }

            // I think the plural form is according to the last one??
            return dngettext (GETTEXT_PACKAGE, "%dm %ds ago", "%dm %ds ago", (ulong) seconds).printf ((int) minutes, (int) seconds);
        }

        return time.format (Granite.DateTime.get_default_time_format ());
    }
}
