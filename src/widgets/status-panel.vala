namespace ExpidusOSShell {
	public class StatusPanel : SidePanel {
		public override PanelSide side {
			get {
				return PanelSide.RIGHT; // TODO: switch to the top on mobile
			}
		}

		public StatusPanel(Shell shell, int monitor_index) {
			Object(shell: shell, monitor_index: monitor_index);

			this.add(new StatusArea(shell));
		}
	}
}
