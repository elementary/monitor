//  /* cpu-graph-model.vala
//   *
//   * Copyright (C) 2018 Red Hat, Inc.
//   * Copyright (C) 2020 stsdc
//   *
//   *
//   * This program is free software: you can redistribute it and/or modify
//   * it under the terms of the GNU General Public License as published by
//   * the Free Software Foundation, either version 3 of the License, or
//   * (at your option) any later version.
//   *
//   * This program is distributed in the hope that it will be useful,
//   * but WITHOUT ANY WARRANTY; without even the implied warranty of
//   * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   * GNU General Public License for more details.
//   *
//   * You should have received a copy of the GNU General Public License
//   * along with this program.  If not, see <http://www.gnu.org/licenses/>.
//   *
//   * Authors: Petr Štětka <pstetka@redhat.com>
//   * Authors: Stanisław <stanisław.dac@gmail.com>
//   */
public class CpuGraphModel : Dazzle.GraphModel {
    public signal void big_process_usage (int column);
    public signal void small_process_usage (int column);
    private bool[] change_big_process_usage;
    private bool[] change_small_process_usage;

    public CpuGraphModel () {
        set_timespan (TimeSpan.MINUTE);
        set_max_samples (100);

        var column_total = new Dazzle.GraphColumn ("TOTAL CPU", Type.DOUBLE);
        add_column (column_total);

        //  change_big_process_usage = new bool[get_num_processors()];
        //  change_small_process_usage = new bool[get_num_processors()];

        //  for (int i = 0; i < get_num_processors(); i++) {
        //      var column_x_cpu = new GraphColumn("CPU: " + i.to_string(), Type.from_name("gdouble"));
        //      add_column(column_x_cpu);

        //      change_big_process_usage[i] = true;
        //      change_small_process_usage[i] = true;
        //  }

        //  Timeout.add(1000, update_data);
    }

    public bool update (double percentage) {
        debug ("Got percentage: %f", percentage);
        Dazzle.GraphModelIter iter;

        push (out iter, get_monotonic_time ());
        iter_set_value (iter, 0, percentage);

        return true;
    }
}
