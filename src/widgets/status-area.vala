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
			this.list.bind_model(new NotificationsListModel(shell), (item) => {
				var notif = item as Notification;
				return new NotificationIcon(notif, Gtk.IconSize.SMALL_TOOLBAR);
			});
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

	public class StatusPanel : SidePanel {
		private Desktop _desktop;

		public override PanelSide side {
			get {
				return this._desktop.monitor.is_mobile ? PanelSide.TOP : PanelSide.RIGHT;
			}
		}

		public StatusPanel(Shell shell, Desktop desktop, int monitor_index) {
			Object(shell: shell, monitor_index: monitor_index, widget_preview: new StatusAreaPreview(shell, desktop), widget_full: new StatusArea(shell, desktop));

			this._desktop = desktop;
		}
	}
}
