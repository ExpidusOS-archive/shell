namespace ExpidusOSShell {
	public class Desktop : Gtk.Window {
		private Shell _shell;
		private int _monitor_index;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public Desktop(Shell shell, int monitor) {
			Object();

			this._shell = shell;
			this._monitor_index = monitor;

			var geo = this.shell.disp.get_monitor(this._monitor_index).geometry;
			this.set_default_size(geo.width, geo.height);
			this.resizable = false;
			this.type_hint = Gdk.WindowTypeHint.DESKTOP;

			var style_ctx = this.get_style_context();
			style_ctx.add_class("expidus-shell-desktop");
			style_ctx.add_class("expidus-shell-desktop-n" + this._monitor_index.to_string());

			this.show_all();
			this.move(geo.x, geo.y);
		}
	}
}
