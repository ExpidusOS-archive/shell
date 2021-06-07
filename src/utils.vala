namespace ExpidusOSShell.Utils {
	public static double get_dpi(ExpidusOSShell.Shell shell, int monitor_index) {
		var monitor = shell.disp.get_monitor(monitor_index);
		var diag_inch = GLib.Math.sqrt(GLib.Math.pow(monitor.width_mm, 2) + GLib.Math.pow(monitor.height_mm, 2)) * 0.039370;
		var diag_px = GLib.Math.sqrt(GLib.Math.pow(monitor.geometry.width, 2) + GLib.Math.pow(monitor.geometry.height, 2));
		return diag_px / diag_inch;
	}

	public static int dpi(ExpidusOSShell.Shell shell, int monitor_index, int v) {
		var dpi = Utils.get_dpi(shell, monitor_index);
		return (int)(v * (dpi / (150 * shell.settings.get_double("scale-factor"))));
	}
}
