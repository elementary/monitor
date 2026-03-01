void main (string[] args) {

    Test.init (ref args);
    Gtk.init ();

    test_statusbar ();
    test_network_connections ();

    Test.run ();
}
