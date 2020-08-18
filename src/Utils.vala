namespace Monitor.Utils {
    const string NOT_AVAILABLE = (_ ("N/A"));
    const string NO_DATA = "\u2014";
}

public class Monitor.Utils.Strings {
    // straight from elementary about-plug

    struct GraphicsReplaceStrings {
        string regex;
        string replacement;
    }

    public static string beautify (string info) {
        string pretty = GLib.Markup.escape_text (info).strip ();


        const GraphicsReplaceStrings REPLACE_STRINGS[] = {
            //  { "Mesa DRI ", ""},
            { "[(]R[)]", "®"},
            { "[(]TM[)]", "™"},
            //  { "Gallium .* on (AMD .*)", "\\1"},
            //  { "(AMD .*) [(].*", "\\1"},
            //  { "(AMD [A-Z])(.*)", "\\1\\L\\2\\E"},
            //  { "Graphics Controller", "Graphics"},
        };

        try {
            foreach (GraphicsReplaceStrings replace_string in REPLACE_STRINGS) {
                GLib.Regex re = new GLib.Regex (replace_string.regex, 0, 0);
                pretty = re.replace (pretty, -1, 0, replace_string.replacement, 0);
            }
        } catch (Error e) {
            critical ("Couldn't cleanup vendor string: %s", e.message);
        }

        return pretty;
    }
}

/**
 * Static helper class for unit formatting
 * Author: Laurent Callarec @lcallarec
 */
public class Monitor.Utils.HumanUnitFormatter {
    const string[] SIZE_UNITS   = {"B", "KiB", "MiB", "GiB", "TiB"};
    const double KFACTOR = 1024;

    /**
     * format a string of bytes to an human readable format with units
     */
    public static string string_bytes_to_human (string bytes) {
        double current_size = double.parse (bytes);
        string current_size_formatted = bytes.to_string () + HumanUnitFormatter.SIZE_UNITS[0];

        for (int i = 0; i<= HumanUnitFormatter.SIZE_UNITS.length; i++) {
            if (current_size < HumanUnitFormatter.KFACTOR) {
                return GLib.Math.round (current_size).to_string () + HumanUnitFormatter.SIZE_UNITS[i];
            }
            current_size = current_size / HumanUnitFormatter.KFACTOR;
        }

        return current_size_formatted;
    }

    public static string double_bytes_to_human (double bytes) {
        string units = _ ("B");

        // convert to MiB if needed
        if (bytes > 1024.0) {
            bytes /= 1024.0;
            units = _ ("KiB");
        }

        // convert to GiB if needed
        if (bytes > 1024.0) {
            bytes /= 1024.0;
            units = _ ("MiB");
        }

        if (bytes > 1024.0) {
            bytes /= 1024.0;
            units = _ ("GiB");
        }

        return "%.1f %s".printf (bytes, units);
    }
}
