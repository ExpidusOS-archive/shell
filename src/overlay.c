#include <expidus-shell/overlay.h>
#include <expidus-shell/shell.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>

typedef struct {
  ExpidusShell* shell;
  int monitor_index;
  gboolean supports_alpha;
  GdkRGBA color;
} ExpidusShellOverlayPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellOverlay, expidus_shell_overlay, GTK_TYPE_WINDOW);

enum {
  PROP_0,
  PROP_SHELL,
  PROP_MONITOR_INDEX,
  N_PROPS
};

static GParamSpec* obj_props[N_PROPS] = { NULL };

static void expidus_shell_overlay_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

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

static void expidus_shell_overlay_get_property(GObject* obj, guint prop_id, GValue* value, GParamSpec* pspec) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

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

static gboolean expidus_shell_overlay_draw(GtkWidget* widget, cairo_t* cr, gpointer data) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(widget);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  g_assert(priv->supports_alpha);
  cairo_set_source_rgba(cr, priv->color.red, priv->color.green, priv->color.blue, priv->color.alpha);
  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
  cairo_paint(cr);
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
  return FALSE;
}

static void expidus_shell_overlay_screen_changed(GtkWidget* widget, GdkScreen* prev, gpointer data) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(widget);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  GdkScreen* screen = gtk_widget_get_screen(widget);
  GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
  if (visual == NULL) {
    visual = gdk_screen_get_system_visual(screen);
    priv->supports_alpha = FALSE;
    g_critical("Display does not support RGBA, overlay cannot function.");
  } else {
    priv->supports_alpha = TRUE;
  }
  gtk_widget_set_visual(widget, visual);
}

static void expidus_shell_overlay_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_overlay_parent_class)->constructed(obj);

  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  priv->color.alpha = 0.0;
  priv->color.red = priv->color.green = priv->color.blue = 1.0;

	GtkWindow* win = GTK_WINDOW(self);
  gtk_window_set_role(win, "expidus-shell-overlay");
  gtk_window_set_decorated(win, FALSE);
  gtk_window_set_type_hint(win, GDK_WINDOW_TYPE_HINT_NORMAL);
  gtk_window_set_skip_taskbar_hint(win, TRUE);
  gtk_window_set_skip_pager_hint(win, TRUE);
  gtk_window_set_focus_on_map(win, FALSE);
  gtk_widget_set_app_paintable(GTK_WIDGET(win), TRUE);
  gtk_window_set_keep_above(win, TRUE);

  g_signal_connect(win, "screen-changed", G_CALLBACK(expidus_shell_overlay_screen_changed), NULL);
  g_signal_connect(win, "draw", G_CALLBACK(expidus_shell_overlay_draw), NULL);

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

  expidus_shell_overlay_screen_changed(GTK_WIDGET(self), NULL, NULL);
	gtk_widget_show_all(GTK_WIDGET(win));
  gdk_window_input_shape_combine_region(gtk_widget_get_window(GTK_WIDGET(win)), cairo_region_create(), 0, 0);
}

static void expidus_shell_overlay_class_init(ExpidusShellOverlayClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->set_property = expidus_shell_overlay_set_property;
  obj_class->get_property = expidus_shell_overlay_get_property;
  obj_class->constructed = expidus_shell_overlay_constructed;

  obj_props[PROP_SHELL] = g_param_spec_object("shell", "Shell", "The ExpidusOS Shell instance to connect to.", EXPIDUS_TYPE_SHELL, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_MONITOR_INDEX] = g_param_spec_uint("monitor-index", "Monitor Index", "The monitor's index to render and use.", 0, 255, 0, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_overlay_init(ExpidusShellOverlay* self) {}