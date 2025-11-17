/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Monitor.Swap : Object {
    public double total { get; private set; default = 0; }
    public double used { get; private set; default = 0; }

    private GTop.Swap swap;

    public int percentage {
        get {
            update ();

            // The total amount of the swap is 0 when it is unavailable
            if (total == 0) {
                return 0;
            } else {
                return (int) (Math.round ((used / total) * 100));
            }
        }
    }

    public Swap () {
        update ();
    }

    public void update () {
        GTop.get_swap (out swap);
        total = (double) (swap.total);
        used = (double) (swap.used);
    }

}
