/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

// This class holds paths to temperature data
// returns contents of the file as a string
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

public class Monitor.HwmonTemperature {
    // temperature channel label
    // temp2_label and temp3_label are supported on SOC15 dGPUs only
    public string _label;
    public string label {
        get {
            if (_label == null) return "";
            return _label;
        }
        set {
            _label = value;
        }
    }
    // the on die temperature in millidegrees Celsius
    // temp2_input and temp3_input are supported on SOC15 dGPUs only
    private string _input;
    public string input {
        owned get {
            return open_file (_input);
        }
        set {
            _input = value;
        }
    }

    // temperature critical max value in millidegrees Celsius
    // temp2_crit and temp3_crit are supported on SOC15 dGPUs only
    public string ? crit;

    // temperature hysteresis for critical limit in millidegrees Celsius
    // temp2_crit_hyst and temp3_crit_hyst are supported on SOC15 dGPUs only
    public string ? crit_hyst;

    //  temperature emergency max value(asic shutdown) in millidegrees Celsius
    // these are supported on SOC15 dGPUs only
    public string ? emergency;

    // Temperature max value.
    public string ? max;

    // Temperature min value.
    public string ? min;

    public string open_file (string filename) {
        try {
            string read;
            FileUtils.get_contents (filename, out read);
            return read.replace ("\n", "");
        } catch (FileError e) {
            warning ("%s", e.message);
            return "";
        }
    }
}
