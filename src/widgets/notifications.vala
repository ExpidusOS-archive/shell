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
}
