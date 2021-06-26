namespace ExpidusOSShell {
	public class AppboardPreview : Gtk.Box {
		private Shell _shell;
		private Desktop _desktop;
		private Gtk.Box box;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public AppboardPreview(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;

			this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			this.add(this.box);
		}
	}

	public class Appboard : Gtk.Box {
		private Shell _shell;
		private Desktop _desktop;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public Appboard(Shell shell, Desktop desktop) {
			this._shell = shell;
			this._desktop = desktop;
		}
	}

	public class AppboardPanel : SidePanel {
		public override PanelSide side {
			get {
				return this.desktop.monitor.is_mobile ? PanelSide.BOTTOM : PanelSide.LEFT;
			}
		}

		public AppboardPanel(Shell shell, Desktop desktop, int monitor_index) {
			Object(shell: shell, desktop: desktop, monitor_index: monitor_index, widget_preview: new AppboardPreview(shell, desktop), widget_full: new Appboard(shell, desktop));
		}
	}
}
