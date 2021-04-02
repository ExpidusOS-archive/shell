#include <expidus-shell/base-dashboard.h>
#include <expidus-shell/shell.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>
#include <expidus-shell-enums.h>

typedef struct {
  int monitor_index;
  ExpidusShell* shell;
  ExpidusShellDashboardStartMode start_mode;
} ExpidusShellBaseDashboardPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellBaseDashboard, expidus_shell_base_dashboard, GTK_TYPE_WINDOW);

enum {
	PROP_0,
	PROP_SHELL,
	PROP_MONITOR_INDEX,
  PROP_START_MODE,
	N_PROPS
};

static GParamSpec* obj_props[N_PROPS] = { NULL };

static void expidus_shell_base_dashboard_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusShellBaseDashboard* self = EXPIDUS_SHELL_BASE_DASHBOARD(obj);
  ExpidusShellBaseDashboardPrivate* priv = expidus_shell_base_dashboard_get_instance_private(self);

  switch (prop_id) {
    case PROP_SHELL:
      priv->shell = g_value_get_object(value);
      break;
    case PROP_MONITOR_INDEX:
      priv->monitor_index = g_value_get_uint(value);
      break;
    case PROP_START_MODE:
      priv->start_mode = g_value_get_enum(value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
      break;
  }
}

static void expidus_shell_base_dashboard_get_property(GObject* obj, guint prop_id, GValue* value, GParamSpec* pspec) {
  ExpidusShellBaseDashboard* self = EXPIDUS_SHELL_BASE_DASHBOARD(obj);
  ExpidusShellBaseDashboardPrivate* priv = expidus_shell_base_dashboard_get_instance_private(self);

  switch (prop_id) {
    case PROP_SHELL:
      g_value_set_object(value, priv->shell);
      break;
    case PROP_MONITOR_INDEX:
      g_value_set_uint(value, priv->monitor_index);
      break;
    case PROP_START_MODE:
      g_value_set_enum(value, priv->start_mode);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
      break;
  }
}

static void expidus_shell_base_dashboard_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_base_dashboard_parent_class)->constructed(obj);

  ExpidusShellBaseDashboard* self = EXPIDUS_SHELL_BASE_DASHBOARD(obj);
  ExpidusShellBaseDashboardPrivate* priv = expidus_shell_base_dashboard_get_instance_private(self);

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

  gtk_window_set_role(win, "expidus-shell-dashboard");
  gtk_window_set_decorated(win, FALSE);
  gtk_window_set_type_hint(win, GDK_WINDOW_TYPE_HINT_NORMAL);
  gtk_window_set_skip_taskbar_hint(win, TRUE);
  gtk_window_set_skip_pager_hint(win, TRUE);
  gtk_window_set_modal(win, TRUE);
  gtk_widget_add_events(GTK_WIDGET(win), GDK_ALL_EVENTS_MASK);
  gtk_window_fullscreen(win);
}

static void expidus_shell_base_dashboard_class_init(ExpidusShellBaseDashboardClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->set_property = expidus_shell_base_dashboard_set_property;
  obj_class->get_property = expidus_shell_base_dashboard_get_property;
	obj_class->constructed = expidus_shell_base_dashboard_constructed;

  obj_props[PROP_SHELL] = g_param_spec_object("shell", "Shell", "The ExpidusOS Shell instance to connect to.", EXPIDUS_TYPE_SHELL, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_MONITOR_INDEX] = g_param_spec_uint("monitor-index", "Monitor Index", "The monitor's index to render and use.", 0, 255, 0, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_START_MODE] = g_param_spec_enum("start-mode", "Startup Mode", "The state of the dashboard on startup", EXPIDUS_TYPE_SHELL_DASHBOARD_START_MODE, EXPIDUS_SHELL_DASHBOARD_START_MODE_NONE, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_base_dashboard_init(ExpidusShellBaseDashboard* self) {}