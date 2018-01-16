namespace Monitor {

    public class MonitorApp : Granite.Application {
        private MainWindow window = null;
        public string[] args;

        construct {
            program_name = "Monitor";
            application_id = "com.github.stsdc.monitor";
            exec_name = "com.github.stsdc.monitor";
            app_launcher = application_id + ".desktop";
        }

        public MonitorApp () {
            Granite.Services.Logger.initialize (this.program_name);
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        }

        public override void activate () {
            // only have one window
            if (get_windows () == null) {
                window = new MainWindow (this);
                window.show_all ();
            } else {
                window.present ();
            }
        }

        public static int main (string [] args) {
            var app = new MonitorApp ();
            return app.run (args);
        }
    }
}
