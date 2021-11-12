// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

[Compact]
public class Monitor.HwmonPWM : Object {
    // pulse width modulation fan level (0-255)
    public string pwm;

    // pulse width modulation fan control minimum level (0)
    public string min;

    // pulse width modulation fan control maximum level (255)
    public string max;

    // pulse width modulation fan control method
    // 0: no fan speed control, 
    // 1: manual fan speed control using pwm interface,
    // 2: automatic fan speed control
    public string enable;
}
