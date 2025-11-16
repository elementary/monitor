/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

public class Monitor.HwmonFrequency {
    // freq channel label
    public string label;

    // freq1_input: the gfx/compute clock in hertz
    // freq2_input: the memory clock in hertz
    public string input;
}
