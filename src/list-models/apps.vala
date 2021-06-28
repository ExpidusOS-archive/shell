namespace ExpidusOSShell {
	public class FavoriteAppsModel : GLib.Object, GLib.ListModel {
		private Shell _shell;
		private uint length;
		private GLib.List<GLib.DesktopAppInfo> apps;

		public FavoriteAppsModel(Shell shell) {
			Object();

			this._shell = shell;
			this.apps = new GLib.List<GLib.DesktopAppInfo>();

			var apps = this._shell.settings.get_strv("favorite-applications");
			for (var i = 0; i < apps.length; i++) {
				var app = new GLib.DesktopAppInfo(apps[i]);
				if (app != null) this.apps.append(app);
			}
			this.length = this.apps.length();
			this._shell.settings.changed["favorite-applications"].connect(this.update);
		}

		~FavoriteAppsModel() {
			this._shell.settings.changed["favorite-applications"].disconnect(this.update);
		}

		private void update() {
			var l = this.length;

			this.items_changed(0, l, 0);

			this.apps = new GLib.List<GLib.DesktopAppInfo>();
			var apps = this._shell.settings.get_strv("favorite-applications");
			for (var i = 0; i < apps.length; i++) {
				var app = new GLib.DesktopAppInfo(apps[i]);
				if (app != null) this.apps.append(app);
			}

			this.length = this.apps.length();
			this.items_changed(0, 0, this.apps.length());
		}

		public Type get_item_type() {
			return typeof (GLib.AppInfo);
		}

		public Object? get_item(uint pos) {
			return this.apps.nth_data(pos);
		}

		public uint get_n_items() {
			return this.apps.length();
		}
	}

	public class RunningAppsModel : GLib.Object, GLib.ListModel {	
		private Shell _shell;
		private GLib.List<Wnck.Application> apps;

		public RunningAppsModel(Shell shell) {
			Object();

			this._shell = shell;
			this.apps = new GLib.List<Wnck.Application>();

			this._shell.wnck_screen.get_windows().@foreach((win) => {
				if (this.apps.index(win.get_application()) == -1 && win.get_window_type() != Wnck.WindowType.DESKTOP && win.get_window_type() != Wnck.WindowType.MENU
					&& win.get_window_type() != Wnck.WindowType.TOOLBAR && win.get_window_type() != Wnck.WindowType.UTILITY) {
					this.apps.append(win.get_application());
				}
			});

			this._shell.wnck_screen.application_opened.connect(this.application_opened);
			this._shell.wnck_screen.application_closed.connect(this.application_closed);
		}

		~RunningAppsModel() {
			this._shell.wnck_screen.application_opened.disconnect(this.application_opened);
			this._shell.wnck_screen.application_closed.disconnect(this.application_closed);
		}

		private void application_opened(Wnck.Application app) {
			if (this.apps.index(app) == -1 && app.get_name() != "expidus-shell") {
				var i = this.apps.length();
				this.apps.append(app);
				this.items_changed(i, 0, 1);
			}
		}

		private void application_closed(Wnck.Application app) {
			var i = this.apps.index(app);
			if (i > 0) this.items_changed(i, 1, 0);
		}

		public Type get_item_type() {
			return typeof (Wnck.Application);
		}

		public Object? get_item(uint pos) {
			return this.apps.nth_data(pos);
		}

		public uint get_n_items() {
			return this.apps.length();
		}
	}
}
