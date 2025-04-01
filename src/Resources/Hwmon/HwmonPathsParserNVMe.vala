/*
 * SPDX-License-Identifier: LGPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.HwmonPathsParserNVMe : Object, IHwmonPathsParserInterface {

    public string name { get; protected set; }

    private Gee.HashMap<int, HwmonTemperature> _temperatures = new Gee.HashMap<int, HwmonTemperature> ();
    public Gee.HashMap<string, HwmonTemperature> temperatures = new Gee.HashMap<string, HwmonTemperature> ();

    protected Gee.HashSet<string> all_paths { get; protected set; }

    construct {
        all_paths = new Gee.HashSet<string> ();
    }

    public void parse () {
        foreach (var path in all_paths) {
            var basename = Path.get_basename (path);
            if (basename.contains ("name")) {
                this.name = basename;
            } else if (basename.contains ("temp")) {
                debug ("Found HWMON NVMe temperature interface path: %s", basename);
                if (!_temperatures.has_key (basename[4])) {
                    _temperatures.set (basename[4], new HwmonTemperature ());
                }

                if (basename.contains ("label")) {
                    _temperatures.get (basename[4]).label = open_file (path);
                } else if (basename.contains ("input")) {
                    _temperatures.get (basename[4]).input = path;
                } else if (basename.contains ("crit")) {
                    _temperatures.get (basename[4]).crit = path;
                } else if (basename.contains ("crit_hyst")) {
                    _temperatures.get (basename[4]).crit_hyst = path;
                } else if (basename.contains ("emergency")) {
                    _temperatures.get (basename[4]).emergency = path;
                } else if (basename.contains ("max")) {
                    _temperatures.get (basename[4]).max = path;
                } else if (basename.contains ("min")) {
                    _temperatures.get (basename[4]).min = path;
                }
            }
        }

        foreach (var paths_holder in _temperatures.values) {
            temperatures.set (paths_holder.label, paths_holder);
            debug ("🌡️ Parsed HWMON NVMe temperature interface: %s", paths_holder.label);
        }
    }
}
