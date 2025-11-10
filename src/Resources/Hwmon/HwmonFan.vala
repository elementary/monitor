/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

public class Monitor.HwmonFan {
    // fan speed in RPM
    public string input;

    // an minimum value Unit: revolution/min (RPM)
    public string min;

    // an maximum value Unit: revolution/min (RPM)
    public string max;

    // Desired fan speed Unit: revolution/min (RPM)
    public string target;

    // Enable or disable the sensors.1: Enable 0: Disable
    public string enable;
}
