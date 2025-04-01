/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

// This struct holds paths to temperature data
// Learn more: https://www.kernel.org/doc/html/v5.11/gpu/amdgpu.html#hwmon-interfaces

[Compact]
public class Monitor.HwmonFrequency : Object {
    // freq channel label
    public string label;

    // freq1_input: the gfx/compute clock in hertz
    // freq2_input: the memory clock in hertz
    public string input;
}
