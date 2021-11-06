// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

[Compact]
public class Monitor.PathsTemp : Object {
    // temperature channel label
    // temp2_label and temp3_label are supported on SOC15 dGPUs only
    public string label;

    // the on die GPU temperature in millidegrees Celsius
    // temp2_input and temp3_input are supported on SOC15 dGPUs only
    public string input;

    // temperature critical max value in millidegrees Celsius
    // temp2_crit and temp3_crit are supported on SOC15 dGPUs only
    public string crit;

    // temperature hysteresis for critical limit in millidegrees Celsius
    // temp2_crit_hyst and temp3_crit_hyst are supported on SOC15 dGPUs only
    public string crit_hyst;

    //  temperature emergency max value(asic shutdown) in millidegrees Celsius
    // these are supported on SOC15 dGPUs only
    public string emergency;
}
