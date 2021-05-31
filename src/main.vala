private const GLib.OptionEntry[] options = {
	{ null }
};

public static int main(string[] args) {
	try {
		var opctx = new GLib.OptionContext("- ExpidusOS Shell");
		opctx.set_help_enabled(true);
		opctx.add_main_entries(options, null);
		opctx.parse(ref args);
	} catch (GLib.OptionError e) {
		stderr.printf("%s: failed to parse arguments: (%s) %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
		return 1;
	}

	Gtk.init(ref args);

	try {
		var shell = new ExpidusOSShell.Shell();
		Gtk.main();
		Xfconf.shutdown();
		return 0;
	} catch (GLib.Error e) {
		stderr.printf("%s: ran into an exception: (%s) %s\n", GLib.Path.get_basename(args[0]), e.domain.to_string(), e.message);
		return 1;
	}
}
