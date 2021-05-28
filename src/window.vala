namespace ExpidusOSShell {
	public abstract class Window : GLib.Object {
		public abstract Shell shell { get; set construct; }
		public abstract Gdk.Window gwin { get; } 
		public abstract Clutter.Texture? texture { get; }

		private Clutter.Actor _actor;

		public Clutter.Actor actor {
			get {
				return this._actor;
			}
		}

		Window() {
			Object();

			this._actor = new Clutter.Actor();
		}

		public abstract void show();
		public abstract void hide();

		public signal void focus();
		public signal void unfocus();
		public signal void map();
		public signal void unmap();
	}
}
