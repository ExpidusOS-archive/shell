namespace ExpidusOSShell {
	public class ExpidusButton : Gtk.Button {
		private Shell shell;
		private Wnck.Window? win = null;
		private Wnck.ActionMenu? menu = null;

		public ExpidusButton(Shell shell) {
			this.shell = shell;
			this.image = new Gtk.Image.from_icon_name("start-here", Gtk.IconSize.SMALL_TOOLBAR);
			this.always_show_image = true;
			this.label = "ExpidusOS";

			var style_ctx = this.get_style_context();
			style_ctx.add_class("expidus-shell-panel-expidusbutton");
			style_ctx.add_class("expidus-shell-panel-button");

			this.shell.wnck_screen.active_window_changed.connect(this.update_with_win);

			this.enter_notify_event.connect((ev) => {
				return this.win != null;
			});
			this.leave_notify_event.connect((ev) => {
				return this.win != null;
			});

			this.clicked.connect(() => {
				if (this.win == null && this.menu == null) {
					this.action();
				} else {
					this.menu.popup_at_widget(this, Gdk.Gravity.SOUTH, Gdk.Gravity.NORTH, null);
				}
			});
		}

		~ExpidusButton() {
			this.shell.wnck_screen.active_window_changed.disconnect(this.update_with_win);
		}

		public signal void action();

		private void reset() {
			var image = this.image as Gtk.Image;
			assert(image != null);

			image.icon_name = "start-here";
			this.label = "ExpidusOS";

			this.win = null;
			this.menu = null;
		}

		private void update_with_win(Wnck.Window? win) {
			var active = this.shell.wnck_screen.get_active_window();

			var image = this.image as Gtk.Image;
			assert(image != null);

			if (active != null) {
				if (active.get_window_type() != Wnck.WindowType.DESKTOP && active.get_window_type() != Wnck.WindowType.MENU
					&& active.get_window_type() != Wnck.WindowType.TOOLBAR && active.get_window_type() != Wnck.WindowType.UTILITY) {
					this.win = active;
					this.menu = new Wnck.ActionMenu(this.win);

					var app = active.get_application();
					if (app != null) {
						this.label = app.get_name();
						if (app.get_mini_icon() != null) image.pixbuf = app.get_mini_icon();
						else if (app.get_icon_name() != null) image.icon_name = app.get_icon_name();
						else image.icon_name = "application-x-executable";
					}
				} else {
					this.reset();
				}
			} else {
				this.reset();
			}
		}
	}
}
