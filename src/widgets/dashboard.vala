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

		private Gtk.Image profile_icon;
		private Gtk.Label profile_label;

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
				if (this.shell.user != null) {
					var row = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);

					if (this.shell.user.icon_file != null) {
						var size = Utils.dpi(this.shell, desktop.monitor.index, 100);
						try {
							this.profile_icon = new Gtk.Image.from_pixbuf(new Gdk.Pixbuf.from_file_at_scale(this.shell.user.icon_file, size, size, true));
							row.pack_start(this.profile_icon, false, false);
						} catch (GLib.Error e) {
							stderr.printf("expidus-shell: failed to load user icon (%s): %s\n", e.domain.to_string(), e.message);
						}
					}

					var name = (this.shell.user.real_name != null && this.shell.user.real_name.length > 0) ? this.shell.user.real_name : this.shell.user.get_user_name();
					this.profile_label = new Gtk.Label(name);
					row.add(this.profile_label);

					this.header_box.pack_start(row, false, false);
				}
			}

			{
				var power_buttons = new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);

				var log_out = new Gtk.Button.from_icon_name("system-log-out");
				var style = log_out.get_style_context();
				style.add_class("expidus-shell-panel-button");
				log_out.clicked.connect(() => this.shell.main_loop.quit());
				power_buttons.add(log_out);

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
		public override PanelSide side {
			get {
				return this.desktop.monitor.is_mobile ? PanelSide.TOP : PanelSide.RIGHT;
			}
		}

		public DashboardPanel(Shell shell, Desktop desktop, int monitor_index) {
			Object(shell: shell, desktop: desktop, monitor_index: monitor_index, widget_preview: new DashboardPreview(shell, desktop), widget_full: new Dashboard(shell, desktop));
		}
	}
}
