namespace ExpidusOSShell {
	public class DashboardPreview : Gtk.Bin {
		private Shell _shell;
		private Desktop _desktop;
		private Gtk.ListBox list;
		private Gtk.Box box;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public DashboardPreview(Shell shell, Desktop desktop) {
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

	public class Dashboard : Gtk.Bin {
		private Shell _shell;
		private Desktop _desktop;

		private Gtk.Box box;
		private Gtk.Box header_box;
		private Gtk.Box main_box;
		private Gtk.Box footer_box;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public Dashboard(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;

			this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			this.header_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			this.main_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			this.footer_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

			this.box.pack_start(this.header_box);
			this.box.set_center_widget(this.main_box);
			this.box.pack_end(this.footer_box);
			this.add(this.box);

			{
				var power_buttons = new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);

				var log_out = new Gtk.Button.from_icon_name("system-log-out");
				var style = log_out.get_style_context();
				style.add_class("expidus-shell-panel-button");
				log_out.clicked.connect(() => this.shell.main_loop.quit());
				power_buttons.add(log_out);

				var lock_screen = new Gtk.Button.from_icon_name("system-lock-screen");
				style = lock_screen.get_style_context();
				style.add_class("expidus-shell-panel-button");
				power_buttons.add(lock_screen);

				if (this.shell.logind.can_reboot) {
					var reboot = new Gtk.Button.from_icon_name("system-reboot");
					style = reboot.get_style_context();
					style.add_class("expidus-shell-panel-button");

					reboot.clicked.connect(() => {
						try {
							this.shell.logind.reboot();
						} catch (GLib.Error e) {}
					});
					power_buttons.add(reboot);
				}

				if (this.shell.logind.can_poweroff) {
					var shutdown = new Gtk.Button.from_icon_name("system-shutdown");
					style = shutdown.get_style_context();
					style.add_class("expidus-shell-panel-button");

					shutdown.clicked.connect(() => {
						try {
							this.shell.logind.poweroff();
						} catch (GLib.Error e) {}
					});
					power_buttons.add(shutdown);
				}

				this.footer_box.pack_end(power_buttons, false, false);
			}
		}
	}

	public class DashboardPanel : SidePanel {
		private Desktop _desktop;

		public override PanelSide side {
			get {
				return this._desktop.monitor.is_mobile ? PanelSide.TOP : PanelSide.RIGHT;
			}
		}

		public DashboardPanel(Shell shell, Desktop desktop, int monitor_index) {
			Object(shell: shell, monitor_index: monitor_index, widget_preview: new DashboardPreview(shell, desktop), widget_full: new Dashboard(shell, desktop));

			this._desktop = desktop;
		}
	}
}
