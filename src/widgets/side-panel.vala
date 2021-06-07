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
						this.get_window().set_shadow_width(0, 0, 0, 0);
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
						if (size == 0) this.hide();
						else {
							this.show_all();
							this.resize(size, monitor.geometry.height - panel_height);
						}

						if (this.mode == SidePanelMode.PREVIEW) {
							this.get_window().set_shadow_width(0, 10, 0, 0);
						} else if (this.mode == SidePanelMode.OPEN) {
							this.get_window().set_shadow_width(0, monitor.geometry.width - size, 0, 0);
						}
						break;
					case PanelSide.RIGHT:
						if (size == 0) this.hide();
						else {
							this.show_all();
							this.resize(size, monitor.geometry.height - panel_height);
						}

						if (this.mode == SidePanelMode.PREVIEW) {
							this.get_window().set_shadow_width(10, 0, 0, 0);
						} else if (this.mode == SidePanelMode.OPEN) {
							this.get_window().set_shadow_width(monitor.geometry.width - size, 0, 0, 0);
						}
						break;
					case PanelSide.TOP:
						if (size == 0) this.hide();
						else {
							this.show_all();
							this.resize(monitor.geometry.width, size);
						}

						if (this.mode == SidePanelMode.PREVIEW) {
							this.get_window().set_shadow_width(0, 0, 0, 10);
						} else if (this.mode == SidePanelMode.OPEN) {
							this.get_window().set_shadow_width(0, 0, 0, monitor.geometry.height - size);
						}
						break;
					case PanelSide.BOTTOM:
						if (size == 0) this.hide();
						else {
							this.show_all();
							this.resize(monitor.geometry.width, size);
						}

						if (this.mode == SidePanelMode.PREVIEW) {
							this.get_window().set_shadow_width(0, 0, 10, 0);
						} else if (this.mode == SidePanelMode.OPEN) {
							this.get_window().set_shadow_width(0, 0, monitor.geometry.height - size, 0);
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
						geo.y = monitor.geometry.y - panel_height;
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
	}
}
