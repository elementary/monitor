namespace Monitor.Utils {
    const string NOT_AVAILABLE = (_("N/A"));
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
            // { "Mesa DRI ", ""},
            { "[(]R[)]", "®" },
            { "[(]TM[)]", "™" },
            // { "Gallium .* on (AMD .*)", "\\1"},
            // { "(AMD .*) [(].*", "\\1"},
            // { "(AMD [A-Z])(.*)", "\\1\\L\\2\\E"},
            // { "Graphics Controller", "Graphics"},
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
    const string[] SIZE_UNITS = { "B", "KiB", "MiB", "GiB", "TiB" };
    const string[] PACKED_SIZE_UNITS = { "B", "K", "M", "G", "T" };
    const double KFACTOR = 1024;

    /**
     * format a string of bytes to an human readable format with units
     */
    public static string string_bytes_to_human (string bytes, bool packed = false) {
        string[] units;

        if (packed)
            units = HumanUnitFormatter.PACKED_SIZE_UNITS;
        else
            units = HumanUnitFormatter.SIZE_UNITS;

        double current_size = double.parse (bytes);
        string current_size_formatted = bytes.to_string () + units[0];

        for (int i = 0; i <= units.length; i++) {
            if (current_size < HumanUnitFormatter.KFACTOR) {
                return GLib.Math.round (current_size).to_string () + units[i];
            }
            current_size = current_size / HumanUnitFormatter.KFACTOR;
        }

        return current_size_formatted;
    }

    public static string double_bytes_to_human (double bytes) {
        string units = _("B");

        // convert to MiB if needed
        if (bytes > 1024.0) {
            bytes /= 1024.0;
            units = _("KiB");
        }

        // convert to GiB if needed
        if (bytes > 1024.0) {
            bytes /= 1024.0;
            units = _("MiB");
        }

        if (bytes > 1024.0) {
            bytes /= 1024.0;
            units = _("GiB");
        }

        return "%.1f %s".printf (bytes, units);
    }

}


public class Monitor.Utils.Colors : Object {



    public const string STRAWBERRY_100 = "#ff8c82";
    public const string STRAWBERRY_300 = "#ed5353";
    public const string STRAWBERRY_500 = "#c6262e";
    public const string STRAWBERRY_700 = "#a10705";
    public const string STRAWBERRY_900 = "#7a0000";

    public const string ORANGE_100 = "#ffc27d";
    public const string ORANGE_300 = "#ffa154";
    public const string ORANGE_500 = "#f37329";
    public const string ORANGE_700 = "#cc3b02";
    public const string ORANGE_900 = "#a62100";

    public const string BANANA_100 = "#fff394";
    public const string BANANA_300 = "#ffe16b";
    public const string BANANA_500 = "#f9c440";
    public const string BANANA_700 = "#d48e15";
    public const string BANANA_900 = "#ad5f00";

    public const string LIME_100 = "#d1ff82";
    public const string LIME_300 = "#9bdb4d";
    public const string LIME_500 = "#68b723";
    public const string LIME_700 = "#3a9104";
    public const string LIME_900 = "#206b00";

    public const string MINT_100 = "#89ffdd";
    public const string MINT_300 = "#43d6b5";
    public const string MINT_500 = "#28bca3";
    public const string MINT_700 = "#0e9a83";
    public const string MINT_900 = "#007367";

    public const string BLUEBERRY_100 = "#8cd5ff";
    public const string BLUEBERRY_300 = "#64baff";
    public const string BLUEBERRY_500 = "#3689e6";
    public const string BLUEBERRY_700 = "#0d52bf";
    public const string BLUEBERRY_900 = "#002e99";

    public const string GRAPE_100 = "#e4c6fa";
    public const string GRAPE_300 = "#cd9ef7";
    public const string GRAPE_500 = "#a56de2";
    public const string GRAPE_700 = "#7239b3";
    public const string GRAPE_900 = "#452981";

    public const string BUBBLEGUM_100 = "#fe9ab8";
    public const string BUBBLEGUM_300 = "#f4679d";
    public const string BUBBLEGUM_500 = "#de3e80";
    public const string BUBBLEGUM_700 = "#bc245d";
    public const string BUBBLEGUM_900 = "#910e38";

    public const string COCOA_100 = "#a3907c";
    public const string COCOA_300 = "#8a715e";
    public const string COCOA_500 = "#715344";
    public const string COCOA_700 = "#57392d";
    public const string COCOA_900 = "#3d211b";

    public const string SILVER_100 = "#fafafa";
    public const string SILVER_300 = "#d4d4d4";
    public const string SILVER_500 = "#abacae";
    public const string SILVER_700 = "#7e8087";
    public const string SILVER_900 = "#555761";

    public const string SLATE_100 = "#95a3ab";
    public const string SLATE_300 = "#667885";
    public const string SLATE_500 = "#485a6c";
    public const string SLATE_700 = "#273445";
    public const string SLATE_900 = "#0e141f";

    public const string BLACK_100 = "#666666";
    public const string BLACK_300 = "#4d4d4d";
    public const string BLACK_500 = "#333333";
    public const string BLACK_700 = "#1a1a1a";
    public const string BLACK_900 = "#000000";

    private Gee.ArrayList<Gdk.RGBA ? > _rgba_colors = new Gee.ArrayList<Gdk.RGBA ? >.wrap ({
        get_rgba_color (Colors.STRAWBERRY_100),
        get_rgba_color (Colors.ORANGE_100),
        get_rgba_color (Colors.BANANA_100),
        get_rgba_color (Colors.LIME_100),
        get_rgba_color (Colors.MINT_100),
        get_rgba_color (Colors.BLUEBERRY_100),
        get_rgba_color (Colors.GRAPE_100),
        get_rgba_color (Colors.BUBBLEGUM_100),
        get_rgba_color (Colors.COCOA_100),
        get_rgba_color (Colors.SILVER_100),
        get_rgba_color (Colors.SLATE_100),
        get_rgba_color (Colors.BLACK_100),

        get_rgba_color (Colors.STRAWBERRY_300),
        get_rgba_color (Colors.ORANGE_300),
        get_rgba_color (Colors.BANANA_300),
        get_rgba_color (Colors.LIME_300),
        get_rgba_color (Colors.MINT_300),
        get_rgba_color (Colors.BLUEBERRY_300),
        get_rgba_color (Colors.GRAPE_300),
        get_rgba_color (Colors.BUBBLEGUM_300),
        get_rgba_color (Colors.COCOA_300),
        get_rgba_color (Colors.SILVER_300),
        get_rgba_color (Colors.SLATE_300),
        get_rgba_color (Colors.BLACK_300),

        get_rgba_color (Colors.STRAWBERRY_500),
        get_rgba_color (Colors.ORANGE_500),
        get_rgba_color (Colors.BANANA_500),
        get_rgba_color (Colors.LIME_500),
        get_rgba_color (Colors.MINT_500),
        get_rgba_color (Colors.BLUEBERRY_500),
        get_rgba_color (Colors.GRAPE_500),
        get_rgba_color (Colors.BUBBLEGUM_500),
        get_rgba_color (Colors.COCOA_500),
        get_rgba_color (Colors.SILVER_500),
        get_rgba_color (Colors.SLATE_500),
        get_rgba_color (Colors.BLACK_500),

        get_rgba_color (Colors.STRAWBERRY_700),
        get_rgba_color (Colors.ORANGE_700),
        get_rgba_color (Colors.BANANA_700),
        get_rgba_color (Colors.LIME_700),
        get_rgba_color (Colors.MINT_700),
        get_rgba_color (Colors.BLUEBERRY_700),
        get_rgba_color (Colors.GRAPE_700),
        get_rgba_color (Colors.BUBBLEGUM_700),
        get_rgba_color (Colors.COCOA_700),
        get_rgba_color (Colors.SILVER_700),
        get_rgba_color (Colors.SLATE_700),
        get_rgba_color (Colors.BLACK_700),
    
        get_rgba_color (Colors.STRAWBERRY_900),
        get_rgba_color (Colors.ORANGE_900),
        get_rgba_color (Colors.BANANA_900),
        get_rgba_color (Colors.LIME_900),
        get_rgba_color (Colors.MINT_900),
        get_rgba_color (Colors.BLUEBERRY_900),
        get_rgba_color (Colors.GRAPE_900),
        get_rgba_color (Colors.BUBBLEGUM_900),
        get_rgba_color (Colors.COCOA_900),
        get_rgba_color (Colors.SILVER_900),
        get_rgba_color (Colors.SLATE_900),
        get_rgba_color (Colors.BLACK_900)
    });



    public Gdk.RGBA get_color_by_index (int index) {
        int int_index; 
        if (index > 60) {
            int_index = index % 60;
        } else {
            int_index = index;
        }

        return _rgba_colors.get (int_index);
    }

    public static Gdk.RGBA get_rgba_color (string hex_code) {
        Gdk.RGBA color = Gdk.RGBA ();
        color.parse (hex_code);
        return color;
    }

}