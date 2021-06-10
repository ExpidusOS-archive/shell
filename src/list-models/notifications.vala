namespace ExpidusOSShell {
	public class NotificationsListModel : GLib.Object, GLib.ListModel {
		private Shell shell;

		public NotificationsListModel(Shell shell) {
			Object();

			this.shell = shell;
			this.shell.notifs.changed.connect(this.items_changed);
		}

		~NotificationsListModel() {
			this.shell.notifs.changed.disconnect(this.items_changed);
		}

		public GLib.Object? get_item(uint pos) {
			return this.shell.notifs.get_notification(pos);
		}

		public GLib.Type get_item_type() {
			return typeof (Notification);
		}

		public uint get_n_items() {
			return this.shell.notifs.count;
		}
	}
}
