#include <expidus-shell/desktop.h>
#include <expidus-shell/shell.h>
#include <flutter_linux/flutter_linux.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>
#include <expidus-build.h>
#include <flutter.h>

typedef struct {
	FlDartProject* proj;
  FlView* view;
	int monitor_index;
	ExpidusShell* shell;
} ExpidusShellDesktopPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDesktop, expidus_shell_desktop, GTK_TYPE_WINDOW);

enum {
	PROP_0,
	PROP_SHELL,
	PROP_MONITOR_INDEX,
	N_PROPS
};

static GParamSpec* obj_props[N_PROPS] = { NULL };

static void expidus_shell_desktop_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

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

static void expidus_shell_desktop_get_property(GObject* obj, guint prop_id, GValue* value, GParamSpec* pspec) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

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

static void expidus_shell_desktop_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->constructed(obj);

  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  GtkWindow* win = GTK_WINDOW(self);
  gtk_window_set_role(win, "expidus-shell-desktop");
  gtk_window_set_decorated(win, FALSE);
  gtk_window_set_type_hint(win, GDK_WINDOW_TYPE_HINT_DESKTOP);
  gtk_window_set_skip_taskbar_hint(win, TRUE);
  gtk_window_set_skip_pager_hint(win, TRUE);
  gtk_window_set_focus_on_map(win, FALSE);

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

	priv->proj = fl_dart_project_new();

	g_clear_pointer(&priv->proj->aot_library_path, g_free);
  g_clear_pointer(&priv->proj->assets_path, g_free);
  g_clear_pointer(&priv->proj->icu_data_path, g_free);

	priv->proj->aot_library_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "libapp.so", NULL);
	priv->proj->assets_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "assets", NULL);
	priv->proj->icu_data_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "icudtl.dat", NULL);

  char* argv[] = { g_strdup_printf("%d", priv->monitor_index), "desktop", NULL };
  fl_dart_project_set_dart_entrypoint_arguments(priv->proj, argv);

  priv->view = fl_view_new(priv->proj);

  gtk_container_add(GTK_CONTAINER(win), GTK_WIDGET(priv->view));
	gtk_widget_show_all(GTK_WIDGET(self));
}

static void expidus_shell_desktop_dispose(GObject* obj) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  g_clear_object(&priv->view);
  g_clear_object(&priv->proj);

  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->dispose(obj);
}

static void expidus_shell_desktop_class_init(ExpidusShellDesktopClass* klass) {
	GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->set_property = expidus_shell_desktop_set_property;
  obj_class->get_property = expidus_shell_desktop_get_property;
  obj_class->constructed = expidus_shell_desktop_constructed;
  obj_class->dispose = expidus_shell_desktop_dispose;

  obj_props[PROP_SHELL] = g_param_spec_object("shell", "Shell", "The ExpidusOS Shell instance to connect to.", EXPIDUS_TYPE_SHELL, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_MONITOR_INDEX] = g_param_spec_uint("monitor-index", "Monitor Index", "The monitor's index to render and use.", 0, 255, 0, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_desktop_init(ExpidusShellDesktop* self) {}