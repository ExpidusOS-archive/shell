#include <expidus-shell/desktop.h>
#include <expidus-shell/flutter.h>
#include <expidus-shell/overlay.h>
#include <expidus-shell/plugin.h>
#include <meta/boxes.h>
#include <meta/display.h>
#include <meta/meta-monitor-manager.h>

typedef struct {
  FlDartProject* proj;
  FlView* view;
  GSList* struts;
  ExpidusShellPlugin* plugin;
  int monitor_index;
  ExpidusShellOverlay* overlay;
} ExpidusShellDesktopPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDesktop, expidus_shell_desktop, GTK_TYPE_WINDOW);

enum {
  PROP_0,
  PROP_PLUGIN,
  PROP_MONITOR_INDEX,
  PROP_OVERLAY,
  N_PROPS
};

static GParamSpec* obj_props[N_PROPS] = { NULL };

static void strut_free(gpointer data) {
  g_slice_free(MetaStrut, data);
}

static void expidus_shell_desktop_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  switch (prop_id) {
    case PROP_PLUGIN:
      priv->plugin = g_value_get_object(value);
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
    case PROP_PLUGIN:
      g_value_set_object(value, priv->plugin);
      break;
    case PROP_MONITOR_INDEX:
      g_value_set_uint(value, priv->monitor_index);
      break;
    case PROP_OVERLAY:
      g_value_set_object(value, priv->overlay);
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

  MetaDisplay* disp = meta_plugin_get_display(META_PLUGIN(priv->plugin));
  MetaRectangle rect;
  meta_display_get_monitor_geometry(disp, priv->monitor_index, &rect);
  gtk_window_move(win, rect.x, rect.y);
  gtk_window_set_default_size(win, rect.width, rect.height);
  gtk_window_set_resizable(win, FALSE);
  gtk_widget_set_size_request(GTK_WIDGET(win), rect.width, rect.height);

  priv->proj = fl_dart_project_new();
  char* argv[] = { g_strdup_printf("%d", priv->monitor_index), "desktop", NULL };
  fl_dart_project_set_dart_entrypoint_arguments(priv->proj, argv);

  priv->view = fl_view_new(priv->proj);

  gtk_widget_show(GTK_WIDGET(priv->view));
  gtk_container_add(GTK_CONTAINER(win), GTK_WIDGET(priv->view));
  flutter_register_plugins(FL_PLUGIN_REGISTRY(priv->view));

  priv->overlay = g_object_new(EXPIDUS_SHELL_TYPE_OVERLAY, "monitor-index", priv->monitor_index, "plugin", priv->plugin, NULL);
}

static void expidus_shell_desktop_dispose(GObject* obj) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  g_clear_object(&priv->view);
  g_clear_object(&priv->proj);
  g_clear_object(&priv->overlay);
  g_clear_slist(&priv->struts, strut_free);

  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->dispose(obj);
}

static void expidus_shell_desktop_class_init(ExpidusShellDesktopClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->set_property = expidus_shell_desktop_set_property;
  obj_class->get_property = expidus_shell_desktop_get_property;
  obj_class->constructed = expidus_shell_desktop_constructed;
  obj_class->dispose = expidus_shell_desktop_dispose;

  obj_props[PROP_PLUGIN] = g_param_spec_object("plugin", "Plugin", "The Mutter Plugin (ExpidusOS Shell) instance to connect to.", EXPIDUS_SHELL_TYPE_PLUGIN, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_MONITOR_INDEX] = g_param_spec_uint("monitor-index", "Monitor Index", "The monitor's index to render and use.", 0, 255, 0, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_OVERLAY] = g_param_spec_object("overlay", "Overlay", "The overlay window", EXPIDUS_SHELL_TYPE_OVERLAY, G_PARAM_READABLE);
  g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_desktop_init(ExpidusShellDesktop* self) {
}

GSList* expidus_shell_desktop_get_struts(ExpidusShellDesktop* self) {
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);
  return priv->struts;
}