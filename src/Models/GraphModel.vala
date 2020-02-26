public class Monitor.GraphModel : Dazzle.GraphModel {

    public GraphModel () {
        set_timespan (TimeSpan.MINUTE);
        set_max_samples (60);

        var column_total = new Dazzle.GraphColumn ("CPU USAGE", Type.DOUBLE);
        add_column (column_total);
    }

    public bool update (double percentage) {
        Dazzle.GraphModelIter iter;

        push (out iter, get_monotonic_time ());
        iter_set_value (iter, 0, percentage);

        return true;
    }
}
