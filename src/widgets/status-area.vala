namespace ExpidusOSShell {
	public class StatusAreaPreview : Gtk.Bin {
		private Shell _shell;
		private Desktop _desktop;
		private Gtk.ListBox list;
		private Gtk.Box box;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public StatusAreaPreview(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;

			this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

			this.list = new Gtk.ListBox();
			/*this.list.bind_model(new NotificationListModel(shell), (item) => {
				return new NotificationIcon(item);
			});*/
			this.box.set_center_widget(this.list);

			this.add(this.box);
		}
	}

	public class StatusArea : Gtk.Box {
		private Shell _shell;
		private Desktop _desktop;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public StatusArea(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;
		}
	}
}
