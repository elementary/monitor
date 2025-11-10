/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

public class Monitor.HwmonVoltage {
    // voltage channel label
    public string label;

    // in0_input: the voltage on the GPU in millivolts
    // in1_input: the voltage on the Northbridge in millivolts
    public string input;
}
