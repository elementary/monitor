/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

public class Monitor.HwmonPower {
    // average power used by the GPU in microWatts
    public string average;

    // average power used by the GPU in microWatts
    public string cap_min;

    // maximum cap supported in microWatts
    public string cap_max;

    // selected power cap in microWatts
    public string cap;
}
