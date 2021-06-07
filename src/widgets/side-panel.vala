namespace ExpidusOSShell {
	public enum SidePanelMode {
		CLOSED,
		PREVIEW,
		OPEN
	}

	public abstract class SidePanel : BasePanel {
		private SidePanelMode _mode = SidePanelMode.CLOSED;

		public int preview_size = 50;
		public int open_size = 250;

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
						break;
					case SidePanelMode.OPEN:
						size = this.open_size;
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
			this.notify.connect((s, p) => {
				if (p.name == "is-active") this.focus_changed();
			});
		}

		private void focus_changed() {
			if (!this.is_active) this.mode = SidePanelMode.CLOSED;
		}
	}
}
