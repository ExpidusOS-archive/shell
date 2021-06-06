namespace ExpidusOSShell {
	public class Desktop : Gtk.Window {
		private Shell _shell;
		private int _monitor_index;
		private Gtk.Grid _grid;
		private Gdk.Pixbuf? _wallpaper;
		private Panel _panel;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public Gtk.Grid grid {
			get {
				return this._grid;
			}
		}

		public Panel panel {
			get {
				return this._panel;
			}
		}

		public Desktop(Shell shell, int monitor) {
			Object();

			this._shell = shell;
			this._monitor_index = monitor;

			var geo = this.shell.disp.get_monitor(this._monitor_index).geometry;
			this.set_default_size(geo.width, geo.height);
			this.resizable = false;
			this.decorated = false;
			this.type_hint = Gdk.WindowTypeHint.DESKTOP;
			this.skip_pager_hint = true;
			this.skip_taskbar_hint = true;

			this._panel = new Panel(this.shell, this._monitor_index);

			var style_ctx = this.get_style_context();
			style_ctx.add_class("expidus-shell-desktop");
			style_ctx.add_class("expidus-shell-desktop-n" + this._monitor_index.to_string());

			this._grid = new Gtk.Grid();
			this.grid.draw.connect((cr) => {
				if (this._wallpaper != null) {
					Gdk.cairo_set_source_pixbuf(cr, this._wallpaper, 0, this.panel.height);
					cr.paint();
				}
				return false;
			});
			this.add(this._grid);

			this.update_wallpaper();

			this.show_all();
			this.move(geo.x, geo.y);

			this.shell.settings.changed["wallpaper-path"].connect(this.update_wallpaper);
		}

		~Desktop() {
			this.shell.settings.changed["wallpaper-path"].disconnect(this.update_wallpaper);
		}

		public void sync() {
			this.update_size();
			this.update_wallpaper();
			this.panel.sync();
		}

		public void update_size() {
			var geo = this.shell.disp.get_monitor(this._monitor_index).geometry;
			this.resize(geo.width, geo.height);
			this.move(geo.x, geo.y);
		}

		public void update_wallpaper() {
			try {
				this._wallpaper = new Gdk.Pixbuf.from_file(this.shell.settings.get_string("wallpaper-path"));
			} catch (GLib.Error error) {
				this._wallpaper = null;
			}

			this.grid.queue_draw();
			this.queue_draw();
		}
	}
}
