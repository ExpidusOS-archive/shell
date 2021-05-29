namespace ExpidusOSShell {
	[DBus(name = "com.expidus.Compositor")]
	public abstract class Compositor : GLib.Object {
		[DBus(visible = false)]
		public abstract Shell shell { get; set construct; }

		[DBus(visible = false)]
		public abstract Gdk.Display disp_gdk { get; }

		[DBus(visible = false)]
		public signal void new_window(BaseWindow win);

		[DBus(visible = false)]
		public abstract bool handle_event();

		[DBus(visible = false)]
		public abstract void init();
	}

	public errordomain CompositorErrors {
		NO_DISPLAY,
		INCOMPATIBLE,
		ALREADY_MANAGED
	}
}
