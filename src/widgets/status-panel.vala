namespace ExpidusOSShell {
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
