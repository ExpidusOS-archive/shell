namespace ExpidusOSShell {
	public class BaseWindow {
		private Shell _shell;
		protected bool framed = false;
		protected Gtk.Window win_frame;
		
		public Shell shell {
			get {
				return this._shell;
			}
			set {
				this._shell = value;
			}
		}

		public virtual Gdk.Window gwin { get; } 
		public virtual Clutter.Texture? texture { get; }
		public virtual bool managed { get; set; }
		public virtual bool is_mapped { get; }
		public virtual int x { get; set; }
		public virtual int y { get; set; }
		public virtual int width { get; set; }
		public virtual int height { get; set; }

		public BaseWindow(Shell shell) {
			this._shell = shell;
			this.win_frame = new Gtk.Window();
		}

		public virtual void show() {
			if (this.framed) {
				this.win_frame.show();
			} else {
				this.texture.show();
			}
		}

		public virtual void hide() {
			if (this.framed) {
				this.win_frame.hide();
			} else {
				this.texture.hide();
			}
		}

		public signal void focus();
		public signal void unfocus();
		public signal void map();
		public signal void unmap();

		public void frame() {
			if (!this.framed) {
				this.win_frame.show_all();
				this.framed = true;
			}
		}

		public void unframe() {
			if (this.framed) {
				this.win_frame.hide();
				this.framed = false;
			}
		}
	}
}
