private static string? backend;

private const GLib.OptionEntry[] options = {
	{ "backend", '\0', GLib.OptionFlags.NONE, GLib.OptionArg.STRING, ref backend, "Use a particular display backend", "BEND" },
	{ null }
};

public static int main(string[] args) {
#if ENABLE_X11
	X.init_threads();
#endif

	try {
		var opctx = new GLib.OptionContext("- ExpidusOS Shell");
		opctx.set_help_enabled(true);
		opctx.add_main_entries(options, null);
		opctx.parse(ref args);
	} catch (GLib.OptionError e) {
		stderr.printf("%s: failed to parse arguments: (%s) %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
		return 1;
	}

	try {
		var shell = new ExpidusOSShell.Shell(backend == null ? "x11" : backend, args);
		while (shell.handle_event());
		return 0;
	} catch (ExpidusOSShell.ShellErrors e) {
		stderr.printf("%s: ran into an exception: (%s) %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
		return 1;
	} catch (ExpidusOSShell.CompositorErrors e) {
		stderr.printf("%s: ran into an exception: (%s) %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
		return 1;
	} catch (GLib.IOError e) {
		stderr.printf("%s: ran into an exception: (%s) %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
		return 1;
	}
}
