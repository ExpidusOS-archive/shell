namespace ExpidusOSShell {
	public abstract class Window : GLib.Object {
		public abstract Shell shell { get; set construct; }
		public abstract Gdk.Window gwin { get; } 
		public abstract Clutter.Stage? stage { get; }

		public signal void focus();
		public signal void unfocus();
		public signal void map();
		public signal void unmap();
	}
}
