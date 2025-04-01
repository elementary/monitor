/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.HwmonPathsParserGPU: Object, IHwmonPathsParserInterface {

    public string name { get; protected set; }

    private Gee.HashMap<int, HwmonTemperature> _temperatures = new Gee.HashMap<int, HwmonTemperature> ();
    public Gee.HashMap<string, HwmonTemperature> temperatures = new Gee.HashMap<string, HwmonTemperature> ();

    private Gee.HashMap<int, HwmonVoltage> _voltages= new Gee.HashMap<int, HwmonVoltage> ();
    public Gee.HashMap<string, HwmonVoltage> voltages = new Gee.HashMap<string, HwmonVoltage> ();

    private Gee.HashMap<int, HwmonFrequency> _frequencies= new Gee.HashMap<int, HwmonFrequency> ();
    public Gee.HashMap<string, HwmonFrequency> frequencies = new Gee.HashMap<string, HwmonFrequency> ();

    public Gee.HashMap<int, HwmonFan> fans= new Gee.HashMap<int, HwmonFan> ();

    public Gee.HashMap<int, HwmonPWM> pwms = new Gee.HashMap<int, HwmonPWM> ();

    public Gee.HashMap<int, HwmonPower> powers = new Gee.HashMap<int, HwmonPower> ();

    protected Gee.HashSet<string> all_paths { get; protected set; }

    construct {
        all_paths = new Gee.HashSet<string> ();
    }

    public void parse () {
        foreach (var path in all_paths) {
            var basename = Path.get_basename (path);
            if (basename.contains ("name")) {
                this.name = open_file (path);
            } else if (basename.contains ("temp")) {
                debug ("Found HWMON GPU temperature interface path: %s", basename);
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
                }

            } else if (basename.has_prefix ("in")) {
                debug ("Found HWMON GPU voltage interface path: %s", basename);
                if (!_voltages.has_key (basename[2])) {
                    _voltages.set (basename[2], new HwmonVoltage ());
                }

                if (basename.contains ("label")) {
                    _voltages.get (basename[2]).label = path;
                } else if (basename.contains ("input")) {
                    _voltages.get (basename[2]).input = path;
                }
            }

            else if (basename.contains ("freq")) {
                debug ("Found HWMON GPU frequnecy interface path: %s", basename);
                if (!_frequencies.has_key (basename[4])) {
                    _frequencies.set (basename[4], new HwmonFrequency ());
                }

                if (basename.contains ("label")) {
                    _frequencies.get (basename[4]).label = path;
                } else if (basename.contains ("input")) {
                    _frequencies.get (basename[4]).input = path;
                }
            }

            else if (basename.contains ("fan")) {
                debug ("Found HWMON GPU fan interface path: %s", basename);
                if (!fans.has_key (basename[3])) {
                    fans.set (basename[3], new HwmonFan ());
                }

                if (basename.contains ("input")) {
                    fans.get (basename[3]).input = path;
                } else if (basename.contains ("max")) {
                    fans.get (basename[3]).max = path;
                } else if (basename.contains ("min")) {
                    fans.get (basename[3]).min = path;
                } else if (basename.contains ("target")) {
                    fans.get (basename[3]).target = path;
                } else if (basename.contains ("enable")) {
                    fans.get (basename[3]).enable = path;
                }
            }

            else if (basename.contains ("pwm")) {
                debug ("Found HWMON GPU PWM interface path: %s", basename);
                if (!pwms.has_key (basename[3])) {
                    pwms.set (basename[3], new HwmonPWM ());
                }

                if (basename == "pwm") {
                    pwms.get (basename[3]).pwm = path;
                } else if (basename.contains ("max")) {
                    pwms.get (basename[3]).max = path;
                } else if (basename.contains ("min")) {
                    pwms.get (basename[3]).min = path;
                } else if (basename.contains ("enable")) {
                    pwms.get (basename[3]).enable = path;
                }
            }

            // `power` is a dir
            else if (basename.contains ("power") && basename != "power") {
                debug ("Found HWMON GPU power interface path: %s", basename);
                if (!powers.has_key (basename[5])) {
                    powers.set (basename[5], new HwmonPower ());
                }

                if (basename.contains ("average")) {
                    powers.get (basename[5]).average = path;
                } else if (basename.contains ("cap_max")) {
                    powers.get (basename[5]).cap_max = path;
                } else if (basename.contains ("cap_min")) {
                    powers.get (basename[5]).cap_min = path;
                } else if (basename.has_suffix ("cap")) {
                    powers.get (basename[5]).cap = path;
                }
            }
        }

        foreach (var holder in _temperatures.values) {
            temperatures.set (holder.label, holder);
            debug ("🌡️ Parsed HWMON GPU temperature interface: %s", holder.label);
        }

        foreach (var holder in _voltages.values) {
            voltages.set (holder.label, holder);
            debug ("⚡ Parsed HWMON GPU voltage interface: %s", open_file (holder.label));
        }

        foreach (var holder in _frequencies.values) {
            frequencies.set (holder.label, holder);
            debug ("⏰ Parsed HWMON GPU frequency interface: %s", holder.label);
        }

        debug ("💨 Parsed HWMON GPU fan interfaces: %d", fans.size);
        debug ("✨ Parsed HWMON GPU PWM interfaces: %d", pwms.size);
        debug ("💪 Parsed HWMON GPU power interfaces: %d", powers.size);

    }
}
