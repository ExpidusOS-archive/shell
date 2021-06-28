namespace ExpidusOSShell {
	public class AppboardPreview : Gtk.Box {
		private Shell _shell;
		private Desktop _desktop;
		private Gtk.Box box;
		private Gtk.ListBox fav_list;
		private Gtk.ListBox running_list;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public AppboardPreview(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;

			this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

			this.fav_list = new Gtk.ListBox();
			this.fav_list.bind_model(new FavoriteAppsModel(this.shell), (item) => {
				return new ApplicationIcon(item as GLib.AppInfo);
			});
			this.box.pack_start(this.fav_list, false, false);

			this.running_list = new Gtk.ListBox();
			this.running_list.bind_model(new RunningAppsModel(this.shell), (item) => {
				return new ApplicationIcon.running(item as Wnck.Application);
			});
			this.box.pack_end(this.running_list, false, false);

			this.add(this.box);
		}
	}

	public class Appboard : Gtk.Box {
		private Shell _shell;
		private Desktop _desktop;
		private Gtk.ListBox apps;
		private GLib.ListStore model;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public Appboard(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;

			var viewport = new Gtk.Viewport(null, null);
			this.apps = new Gtk.ListBox();
			this.model = new GLib.ListStore(typeof (GLib.AppInfo));
			this.apps.bind_model(this.model, (item) => {
				return new ApplicationLauncher(this.shell, item as GLib.AppInfo);
			});

			viewport.add(this.apps);
			this.add(viewport);

			this.update();
		}

		private void update() {
			var app_infos = GLib.AppInfo.get_all();
			if (this.model.get_n_items() != app_infos.length()) {
				this.model.remove_all();
				app_infos.@foreach((app) => {
					if (app.should_show()) {
						this.model.append(app);
					}
				});

				this.model.sort((_a, _b) => {
					var a = _a as GLib.AppInfo;
					assert(a != null);

					var b = _b as GLib.AppInfo;
					assert(b != null);
					return a.get_name().ascii_casecmp(b.get_name());
				});
			}
		}

		public void init(AppboardPanel panel) {
			panel.mode_changed.connect(() => {
				if (panel.mode == SidePanelMode.OPEN) {
					this.update();
				}
			});
		}
	}

	public class AppboardPanel : SidePanel {
		public override PanelSide side {
			get {
				return this.desktop.monitor.is_mobile ? PanelSide.BOTTOM : PanelSide.LEFT;
			}
		}

		public AppboardPanel(Shell shell, Desktop desktop, int monitor_index) {
			Object(shell: shell, desktop: desktop, monitor_index: monitor_index, widget_preview: new AppboardPreview(shell, desktop), widget_full: new Appboard(shell, desktop));

			var appboard = this.widget_full as Appboard;
			assert(appboard != null);
			appboard.init(this);
		}
	}
}
