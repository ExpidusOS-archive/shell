namespace ExpidusOSShell {
	public class BaseWindow {
		private Shell _shell;
		protected bool framed = false;
		
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
		}

		public virtual void show() {
			this.texture.show();
		}

		public virtual void hide() {
			this.texture.hide();
		}

		public signal void focus();
		public signal void unfocus();
		public signal void map();
		public signal void unmap();
		public signal void resize(int old_width, int old_height, int new_width, int new_height);
		public signal void move(int old_x, int old_y, int new_x, int new_y);

		public virtual void frame() {
		}

		public virtual void unframe() {
		}
	}
}
