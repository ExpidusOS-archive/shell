namespace ExpidusOSShell {
	public class Panel : BasePanel {
		private GLib.TimeoutSource clock_timer;

		private Gtk.Box box_left;
		private Gtk.Box box_center;
		private Gtk.Box box_right;
		private Gtk.Box box;

		private Gtk.Button clock;

		public override Gdk.Rectangle geometry {
			get {
				var height = Utils.dpi(this.shell, this.monitor_index, 45);
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

		public Panel(Shell shell, int monitor_index) {
			Object(shell: shell, monitor_index: monitor_index);

			var style_ctx = this.get_style_context();
			style_ctx.add_class("expidus-shell-panel");
			style_ctx.add_class("expidus-shell-panel-n" + this.monitor_index.to_string());

			this.box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			this.box_left = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
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

			this.clock = new Gtk.Button.with_label("00:00 AM");
			style_ctx = this.clock.get_style_context();
			style_ctx.add_class("expidus-shell-panel-clock");
			this.box_right.pack_end(this.clock, false, false);

			this.clock.enter_notify_event.connect((ev) => {
				var monitor = this.shell.get_monitor(this.monitor_index);
				assert(monitor != null);
				monitor.desktop.status_panel.mode = SidePanelMode.PREVIEW;
				return false;
			});

			this.clock.leave_notify_event.connect((ev) => {
				var monitor = this.shell.get_monitor(this.monitor_index);
				assert(monitor != null);
				if (monitor.desktop.status_panel.mode == SidePanelMode.PREVIEW) {
					monitor.desktop.status_panel.mode = SidePanelMode.CLOSED;
				}
				return false;
			});

			this.clock.clicked.connect(() => {
				var monitor = this.shell.get_monitor(this.monitor_index);
				assert(monitor != null);
				if (monitor.desktop.status_panel.mode == SidePanelMode.OPEN) {
					monitor.desktop.status_panel.mode = SidePanelMode.CLOSED;
				} else {
					monitor.desktop.status_panel.mode = SidePanelMode.OPEN;
				}
			});

			this.clock_timer = new GLib.TimeoutSource(1000);
			this.clock_timer.set_callback(() => {
				var dt = new GLib.DateTime.now();
				this.clock.label = dt.format("%I:%M %p");
				this.clock.set_tooltip_text(dt.format("%a %b %e %I:%M %p %Y"));
				return true;
			});
			this.clock_timer.attach(this.shell.main_loop.get_context());

			this.show_all();
		}

		~Panel() {
			this.clock_timer.destroy();
		}
	}
}
