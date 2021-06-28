namespace ExpidusOSShell {
	public class ApplicationIcon : Gtk.Bin {
		private Gtk.Image img;

		public ApplicationIcon(GLib.AppInfo? app) {
			this.img = new Gtk.Image();

			if (app == null) {
				this.img.set_from_icon_name("image-missing", Gtk.IconSize.SMALL_TOOLBAR);
			} else {
				if (app.get_icon() == null) {
					this.img.set_from_icon_name("application-x-executable", Gtk.IconSize.SMALL_TOOLBAR);
				} else {
					this.img.set_from_gicon(app.get_icon(), Gtk.IconSize.SMALL_TOOLBAR);
				}
			}

			this.add(this.img);
			this.show_all();
		}

		public ApplicationIcon.running(Wnck.Application? app) {
			this.img = new Gtk.Image();

			if (app == null) {
				this.img.set_from_icon_name("image-missing", Gtk.IconSize.SMALL_TOOLBAR);
			} else {
				if (app.get_icon() == null) {
					this.img.set_from_icon_name("application-x-executable", Gtk.IconSize.SMALL_TOOLBAR);
				} else {
					this.img.set_from_gicon(app.get_icon(), Gtk.IconSize.SMALL_TOOLBAR);
				}
			}

			this.add(this.img);
			this.show_all();
		}
	}

	public class ApplicationLauncher : Gtk.Button {
		public ApplicationLauncher(Shell shell, GLib.AppInfo app) {
			this.always_show_image = true;
			this.image = new ApplicationIcon(app);
			this.label = app.get_name();
			
			this.clicked.connect(() => {
				try {
					app.launch(null, null);
				} catch (GLib.Error e) {
					stderr.printf("expidus-shell: failed to start \"%s\" (%s): %s\n", app.get_id(), e.domain.to_string(), e.message);
				}
			});
		}
	}
}
