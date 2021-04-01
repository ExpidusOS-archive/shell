#include <gdk/gdkx.h>
#define WNCK_I_KNOW_THIS_IS_UNSTABLE 1
#include <expidus-shell/utils.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>

char* wnck_window_get_property_string(WnckWindow* win, const char* name) {
  Window xwin = wnck_window_get_xid(win);
	Display* disp = GDK_DISPLAY_XDISPLAY(gdk_display_get_default());
	Atom prop = gdk_x11_get_xatom_by_name(name);
	g_return_val_if_fail(prop != None, NULL);

	Atom actual_type;
	int actual_format;
	unsigned long n_items;
	unsigned long bytes_after;
	unsigned char* value;
	if (XGetWindowProperty(disp, xwin, prop, 0, G_MAXLONG, False, AnyPropertyType, &actual_type, &actual_format, &n_items, &bytes_after, &value) == Success) {
		if (actual_format) {
			char* str = g_strdup((const char*)value);
			if (value != NULL) XFree(value);
			return str;
		}
	}
	return NULL;
}