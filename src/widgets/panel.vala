namespace ExpidusOSShell {
	public class Panel : BasePanel {
		private GLib.TimeoutSource clock_timer;
		private Desktop desktop;

		private Gtk.Box box_left;
		private Gtk.Box box_center;
		private Gtk.Box box_right;
		private Gtk.Box box;

		private SoundIndicator _sound;
		private NetworkIndicator net;
		private BatteryIndicator battery;

		private ExpidusButton expidus_button;

		private Gtk.Button clock;

		public SoundIndicator sound {
			get {
				return this._sound;
			}
		}

		public override Gdk.Rectangle geometry {
			get {
				var height = Utils.dpi(this.shell, this.monitor_index, 50);
				var geo = this.shell.disp.get_monitor(this.monitor_index).geometry;
				Gdk.Rectangle rect = {
					x: geo.x,
					y: geo.y,
					width: geo.width,
					height: height
				};
				return rect;
			}
		}

		public override PanelSide side {
			get {
				return PanelSide.TOP;
			}
		}

		public Panel(Shell shell, Desktop desktop, int monitor_index) {
			Object(shell: shell, monitor_index: monitor_index);
			this.desktop = desktop;

			var style_ctx = this.get_style_context();
			style_ctx.add_class("expidus-shell-panel");
			style_ctx.add_class("expidus-shell-panel-n" + this.monitor_index.to_string());

			this.box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this.box_left = new Gtk.Box(Gtk.Orientation.HORIZONTAL, desktop.monitor.is_mobile ? 4 : 0);
			this.box_center = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this.box_right = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

			this.box.baseline_position = Gtk.BaselinePosition.CENTER;
			this.box_left.baseline_position = Gtk.BaselinePosition.CENTER;
			this.box_center.baseline_position = Gtk.BaselinePosition.CENTER;
			this.box_right.baseline_position = Gtk.BaselinePosition.CENTER;

			this.box.pack_start(this.box_left, false, false);
			this.box.set_center_widget(this.box_center);
			this.box.pack_end(this.box_right, false, false);

			this.add(this.box);

			this.event.connect((ev) => {
				switch (ev.type) {
					case Gdk.EventType.BUTTON_RELEASE:
					case Gdk.EventType.TOUCH_END:
						if (desktop.monitor.is_mobile) {	
							if (desktop.dashboard_panel.mode == SidePanelMode.OPEN) {
								desktop.dashboard_panel.mode = SidePanelMode.CLOSED;
							} else {
								desktop.dashboard_panel.mode = SidePanelMode.OPEN;
							}
						}
						return true;
					default:
						break;
				}
				return false;
			});

			this.clock = new Gtk.Button.with_label("00:00 AM");
			style_ctx = this.clock.get_style_context();
			style_ctx.add_class("expidus-shell-panel-clock");
			style_ctx.add_class("expidus-shell-panel-button");
			this.box_right.pack_end(this.clock, false, false);

			if (!desktop.monitor.is_mobile) {
				this.expidus_button = new ExpidusButton(shell);
				this.expidus_button.enter_notify_event.connect((ev) => {
					desktop.appboard_panel.mode = SidePanelMode.PREVIEW;
					return false;
				});

				this.expidus_button.leave_notify_event.connect((ev) => {
					if (desktop.appboard_panel.mode == SidePanelMode.PREVIEW) {
						desktop.dashboard_panel.mode = SidePanelMode.CLOSED;
					}
					return false;
				});

				this.expidus_button.action.connect(() => {
					if (desktop.appboard_panel.mode == SidePanelMode.OPEN) {
						desktop.appboard_panel.mode = SidePanelMode.CLOSED;
					} else {
						desktop.appboard_panel.mode = SidePanelMode.OPEN;
					}
				});
				this.box_left.pack_start(this.expidus_button);

				this.clock.enter_notify_event.connect((ev) => {
					desktop.dashboard_panel.mode = SidePanelMode.PREVIEW;
					return false;
				});

				this.clock.leave_notify_event.connect((ev) => {
					if (desktop.dashboard_panel.mode == SidePanelMode.PREVIEW) {
						desktop.dashboard_panel.mode = SidePanelMode.CLOSED;
					}
					return false;
				});

				this.clock.clicked.connect(() => {
					if (desktop.dashboard_panel.mode == SidePanelMode.OPEN) {
						desktop.dashboard_panel.mode = SidePanelMode.CLOSED;
					} else {
						desktop.dashboard_panel.mode = SidePanelMode.OPEN;
					}
				});
			} else {
				GLib.HashTable<Notification, NotificationIcon> notifs = new GLib.HashTable<Notification,NotificationIcon>(GLib.direct_hash, GLib.direct_equal);

				this.shell.notifs.notified.connect((notif) => {
					var w = new NotificationIcon(notif, Gtk.IconSize.SMALL_TOOLBAR);
					notifs.insert(notif, w);
					this.box_left.add(w);
				});

				this.shell.notifs.NotificationClosed.connect((id, reason) => {
					var notif = shell.notifs.find(id);
					if (notif != null && notifs.get(notif) != null) {
						this.box_left.remove(notifs.get(notif));
					}
				});
			}

			this.battery = new BatteryIndicator(this.shell);
			this.box_right.add(this.battery);

			this.net = new NetworkIndicator(this.shell);
			this.box_right.add(this.net);

			this._sound = new SoundIndicator(this.shell);
			this.box_right.add(this.sound);

			this.clock_timer = new GLib.TimeoutSource(1000);
			this.clock_timer.set_callback(() => {
				var dt = new GLib.DateTime.now();
				this.clock.label = dt.format("%I:%M %p");
				this.clock.set_tooltip_text(dt.format("%a %b %e %I:%M %p %Y"));
				return true;
			});
			this.clock_timer.attach(this.shell.main_loop.get_context());

			this.show_all();
			this.net.update();
			this.battery.update();
		}

		~Panel() {
			this.clock_timer.destroy();
		}
	}
}
