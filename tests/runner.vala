void main (string[] args) {

    Test.init (ref args);
    Gtk.init (ref args);

    test_statusbar ();

    Test.run ();
}
