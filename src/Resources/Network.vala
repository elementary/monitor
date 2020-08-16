/*-
 * Copyright (c) 2020 Tudor Plugaru (https://github.com/PlugaruT/wingpanel-monitor)
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
        private int _bytes_in;
        private int _bytes_in_old;
        private bool control;

        private int _bytes_out;
        private int _bytes_out_old;

        private int i;

        // flag first run
        // bc first calculasion is wrong
        private bool dumb_flag;

        public Network () {
            _bytes_in = 0;
            _bytes_in_old = 0;
            _bytes_out = 0;
            _bytes_out_old = 0;
            control = false;
            dumb_flag = true;
        }

        public int[] get_bytes () {
            if (control == false) {
                control = true;
                update_bytes_total ();
            } else {
                control = false;
            }
            int[] ret;
            ret = {_bytes_out, _bytes_in};
            return ret;
        }

        private void update_bytes_total () {
            GTop.NetList netlist;
            GTop.NetLoad netload;

            var devices = GTop.get_netlist (out netlist);
            var n_bytes_out = 0;
            var n_bytes_in = 0;
            for (uint j = 0; j < netlist.number; ++j) {
                var device = devices[j];
                if (device != "lo" && device.substring (0, 3) != "tun") {
                    GTop.get_netload (out netload, device);

                    n_bytes_out += (int)netload.bytes_out;
                    n_bytes_in += (int)netload.bytes_in;
                }
            }

            var bout = (n_bytes_out - _bytes_out_old) / 1;
            var bin = (n_bytes_in - _bytes_in_old) / 1;
            
            _bytes_out_old = n_bytes_out;
            _bytes_in_old = n_bytes_in;
            
            if (!dumb_flag) {
                _bytes_out = bout;
                _bytes_in = bin;

                debug ("%d", i);
                i++;
            } 
            dumb_flag = false;

        }
    }
