/*-
 * Copyright (c) 2020 Tudor Plugaru, @stsdc
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Tudor Plugaru <plugaru.tudor@gmail.com>
 */


public class Monitor.Network : GLib.Object {
    public int bytes_in;
    private int bytes_in_old;

    public int bytes_out;
    private int bytes_out_old;

    // flag first run
    // bc first calculasion is wrong
    private bool dumb_flag;

    public Network () {
        bytes_in = 0;
        bytes_in_old = 0;
        bytes_out = 0;
        bytes_out_old = 0;
        dumb_flag = true;
    }

    public void update () {
        GTop.NetList netlist;
        GTop.NetLoad netload;

        var devices = GTop.get_netlist (out netlist);
        var bytes_out_new = 0;
        var bytes_in_new = 0;
        for (uint j = 0; j < netlist.number; ++j) {
            var device = devices[j];
            if (device != "lo" && device.substring (0, 3) != "tun") {
                GTop.get_netload (out netload, device);

                bytes_out_new += (int) netload.bytes_out;
                bytes_in_new += (int) netload.bytes_in;
            }
        }

        if (!dumb_flag) {
            bytes_out = (bytes_out_new - bytes_out_old) / MonitorApp.settings.get_int ("update-time");
            bytes_in = (bytes_in_new - bytes_in_old) / MonitorApp.settings.get_int ("update-time");
        }

        bytes_out_old = bytes_out_new;
        bytes_in_old = bytes_in_new;


        dumb_flag = false;
    }

}
