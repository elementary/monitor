public class Monitor.ProcessUtils {


    private static bool is_shell (string chunk) {
        if ("sh" == chunk || "bash" == chunk || "zsh" == chunk) {
            debug (chunk);
            return true;
        }
        return false;
    }


    public static string sanitize_commandline (string commandline) {
        // splitting command; might include many options
        var splitted_commandline = commandline.split (" ");

        // check if started by any shell
        if (is_shell(splitted_commandline[0])) {
            return Path.get_basename (splitted_commandline[1]);
        }

        return Path.get_basename (splitted_commandline[0]);
    }
}