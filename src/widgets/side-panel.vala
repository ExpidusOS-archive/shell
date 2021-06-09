namespace ExpidusOSShell {
	public enum SidePanelMode {
		CLOSED,
		PREVIEW,
		OPEN
	}

	public abstract class SidePanel : BasePanel {
		private Gtk.Stack stack;
		private SidePanelMode _mode = SidePanelMode.CLOSED;
		private Gtk.Widget _widget_preview;
		private Gtk.Widget _widget_full;

		public int preview_size = 50;
		public int open_size = 250;

		public Gtk.Widget widget_preview {
			get {
				return this._widget_preview;
			}
			set construct {
				this._widget_preview = value;
			}
		}

		public Gtk.Widget widget_full {
			get {
				return this._widget_full;
			}
			set construct {
				this._widget_full = value;
			}
		}

		public SidePanelMode mode {
			get {
				return this._mode;
			}
			set {
				this._mode = value;

				var monitor = this.shell.disp.get_monitor(this.monitor_index);
				var panel_height = Utils.dpi(this.shell, this.monitor_index, 45);
				var size = 0;
				switch (this.mode) {
					case SidePanelMode.CLOSED:
						break;
					case SidePanelMode.PREVIEW:
						size = this.preview_size;
						break;
					case SidePanelMode.OPEN:
						size = this.open_size;
						break;
				}

				switch (this.side) {
					case PanelSide.LEFT:
					case PanelSide.RIGHT:
						if (size == 0) this.hide();
						else {
							this.show_all();
							this.resize(size, monitor.geometry.height - panel_height);
						}
						break;
					case PanelSide.TOP:
					case PanelSide.BOTTOM:
						if (size == 0) this.hide();
						else {
							this.show_all();
							this.resize(monitor.geometry.width, size);
						}
						break;
				}

				this.queue_resize();
				this.queue_draw();
			}
		}

		public override Gdk.Rectangle geometry {
			get {
				var monitor = this.shell.disp.get_monitor(this.monitor_index);
				Gdk.Rectangle geo = {};

				var panel_height = Utils.dpi(this.shell, this.monitor_index, 45);

				var size = 0;
				var height = monitor.geometry.height;

				switch (this.mode) {
					case SidePanelMode.CLOSED:
						break;
					case SidePanelMode.PREVIEW:
						size = this.preview_size;
						this.stack.visible_child_name = "preview";
						break;
					case SidePanelMode.OPEN:
						size = this.open_size;
						this.stack.visible_child_name = "full";
						break;
				}

				switch (this.side) {
					case PanelSide.LEFT:
						geo.x = monitor.geometry.x;
						geo.y = monitor.geometry.y - panel_height;
						geo.width = size;
						geo.height = height - panel_height;
						break;
					case PanelSide.RIGHT:
						geo.x = monitor.geometry.x + monitor.geometry.width - size;
						geo.y = monitor.geometry.y + panel_height;
						geo.width = size;
						geo.height = height - panel_height;
						break;
					case PanelSide.TOP:
						geo.x = monitor.geometry.x;
						geo.y = monitor.geometry.y + panel_height;
						geo.width = monitor.geometry.width;
						geo.height = size;
						break;
					case PanelSide.BOTTOM:
						geo.x = monitor.geometry.x;
						geo.y = monitor.geometry.y + monitor.geometry.height - size;
						geo.width = monitor.geometry.width;
						geo.height = size;
						break;
				}

				return geo;
			}
		}

		construct {
			this.add_events(Gdk.EventMask.ALL_EVENTS_MASK);

			this.stack = new Gtk.Stack();
			this.stack.add_named(this.widget_preview, "preview");
			this.stack.add_named(this.widget_full, "full");
			this.add(this.stack);

			this.event.connect((ev) => {
				if (ev.type == Gdk.EventType.LEAVE_NOTIFY) {
					this.mode = SidePanelMode.CLOSED;
				}
				return false;
			});
		}
	}
}
