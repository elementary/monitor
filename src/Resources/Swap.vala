public class Monitor.Swap : Object {
    public double total { get; private set; default = 0; }
    public double used { get; private set; default = 0; }

    private GTop.Swap swap;

    public int percentage {
        get {
            update ();
            return (int) (Math.round ((used / total) * 100));
        }
    }

    public Swap () {
    }

    private void update () {
        GTop.get_swap (out swap);
        total = (double) (swap.total / 1024 / 1024) / 1000;
        used = (double) (swap.used / 1024 / 1024) / 1000;
    }
}
