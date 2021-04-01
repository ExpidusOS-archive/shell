#include <expidus-shell/base-desktop.h>
#include <expidus-shell/shell.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>

typedef struct {
	int monitor_index;
	ExpidusShell* shell;
} ExpidusShellBaseDesktopPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellBaseDesktop, expidus_shell_base_desktop, GTK_TYPE_WINDOW);

enum {
	PROP_0,
	PROP_SHELL,
	PROP_MONITOR_INDEX,
	N_PROPS
};

static GParamSpec* obj_props[N_PROPS] = { NULL };

static void expidus_shell_base_desktop_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusShellBaseDesktop* self = EXPIDUS_SHELL_BASE_DESKTOP(obj);
  ExpidusShellBaseDesktopPrivate* priv = expidus_shell_base_desktop_get_instance_private(self);

  switch (prop_id) {
    case PROP_SHELL:
      priv->shell = g_value_get_object(value);
      break;
    case PROP_MONITOR_INDEX:
      priv->monitor_index = g_value_get_uint(value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
      break;
  }
}

static void expidus_shell_base_desktop_get_property(GObject* obj, guint prop_id, GValue* value, GParamSpec* pspec) {
  ExpidusShellBaseDesktop* self = EXPIDUS_SHELL_BASE_DESKTOP(obj);
  ExpidusShellBaseDesktopPrivate* priv = expidus_shell_base_desktop_get_instance_private(self);

  switch (prop_id) {
    case PROP_SHELL:
      g_value_set_object(value, priv->shell);
      break;
    case PROP_MONITOR_INDEX:
      g_value_set_uint(value, priv->monitor_index);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
      break;
  }
}

static void expidus_shell_base_desktop_constructed(GObject* obj) {
	ExpidusShellBaseDesktop* self = EXPIDUS_SHELL_BASE_DESKTOP(obj);
	ExpidusShellBaseDesktopPrivate* priv = expidus_shell_base_desktop_get_instance_private(self);

	GtkWindow* win = GTK_WINDOW(self);

	MetaPlugin* plugin;
	g_object_get(priv->shell, "plugin", &plugin, NULL);
	g_assert(plugin);

	MetaDisplay* disp = meta_plugin_get_display(plugin);
  MetaRectangle rect;
  meta_display_get_monitor_geometry(disp, priv->monitor_index, &rect);
  gtk_window_move(win, rect.x, rect.y);
  gtk_window_set_default_size(win, rect.width, rect.height);
  gtk_window_set_resizable(win, FALSE);
  gtk_widget_set_size_request(GTK_WIDGET(win), rect.width, rect.height);
  gtk_window_set_accept_focus(win, FALSE);

  gtk_window_set_role(win, "expidus-shell-desktop");
  gtk_window_set_decorated(win, FALSE);
  gtk_window_set_type_hint(win, GDK_WINDOW_TYPE_HINT_DESKTOP);
  gtk_window_set_skip_taskbar_hint(win, TRUE);
  gtk_window_set_skip_pager_hint(win, TRUE);
  gtk_window_set_focus_on_map(win, FALSE);
}

static void expidus_shell_base_desktop_class_init(ExpidusShellBaseDesktopClass* klass) {
	GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->set_property = expidus_shell_base_desktop_set_property;
  obj_class->get_property = expidus_shell_base_desktop_get_property;
	obj_class->constructed = expidus_shell_base_desktop_constructed;

  obj_props[PROP_SHELL] = g_param_spec_object("shell", "Shell", "The ExpidusOS Shell instance to connect to.", EXPIDUS_TYPE_SHELL, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_MONITOR_INDEX] = g_param_spec_uint("monitor-index", "Monitor Index", "The monitor's index to render and use.", 0, 255, 0, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_base_desktop_init(ExpidusShellBaseDesktop* self) {}

GSList* expidus_shell_base_desktop_get_struts(ExpidusShellBaseDesktop* self) {
  g_return_val_if_fail(EXPIDUS_SHELL_IS_BASE_DESKTOP(self), NULL);
	ExpidusShellBaseDesktopClass* klass = EXPIDUS_SHELL_BASE_DESKTOP_GET_CLASS(self);
  g_return_val_if_fail(klass, NULL);
  return klass->get_struts != NULL ? klass->get_struts(self) : NULL;
}