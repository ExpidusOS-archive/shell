namespace ExpidusOSShell {
	public class NotificationIcon : Gtk.Bin {
		private Notification _notif;
		private Gtk.Image img;

		public Notification notif {
			get {
				return this._notif;
			}
		}

		public NotificationIcon(Notification notif, Gtk.IconSize icon_size) {
			this._notif = notif;
			this.img = new Gtk.Image();

			if (notif.app_icon.length > 0 && !notif.app_icon.contains("://")) {
				this.img.set_from_icon_name(notif.app_icon, icon_size);
			} else {
				this.img.set_from_icon_name("application-x-executable", icon_size);
			}

			this.add(this.img);
			this.show_all();
		}
	}
	public class NotificationBox : Gtk.Button {
		private Gtk.Box box;
		private Notification _notif;
		private Gtk.Image img;
		private Gtk.Label app_name;
		private Gtk.Label content;

		public Notification notif {
			get {
				return this._notif;
			}
		}

		public NotificationBox(Notification notif) {
			this._notif = notif;

			this.box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
			this.img = new Gtk.Image();

			if (notif.app_icon.length > 0 && !notif.app_icon.contains("://")) {
				this.img.set_from_icon_name(notif.app_icon, Gtk.IconSize.LARGE_TOOLBAR);
			} else {
				this.img.set_from_icon_name("application-x-executable", Gtk.IconSize.LARGE_TOOLBAR);
			}

			this.box.pack_start(this.img, false, false);

			this.app_name = new Gtk.Label(null);
			this.app_name.set_markup("<b>" + this.notif.app_name + "</b>");

			this.content = new Gtk.Label(null);
			this.content.set_markup(this.notif.summary);

			var vert_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 2);
			vert_box.pack_start(this.app_name, false, false);
			vert_box.pack_end(this.content, false, false);
			this.box.add(vert_box);

			this.clicked.connect(() => {
				if (this.notif.actions.length > 0) this.notif.invoke(this.notif.actions[0]);
			});

			this.add(this.box);
			this.show_all();
		}
	}
}
