namespace ExpidusOSShell {
	public class StatusArea : Gtk.Box {
		private Shell _shell;

		public Shell shell {
			get {
				return this._shell;
			}
		}

		public StatusArea(Shell shell) {
			this._shell = shell;
		}
	}
}
