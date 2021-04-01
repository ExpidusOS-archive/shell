#include <expidus-shell/ui/dashboard.h>
#include <expidus-shell/shell.h>
#include <expidus-build.h>
#include <flutter.h>

typedef struct {
	FlDartProject* proj;
  FlView* view;
  FlMethodChannel* channel_dart;
  FlMethodChannel* channel;

  gboolean supports_alpha;
} ExpidusShellDashboardPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDashboard, expidus_shell_dashboard, EXPIDUS_SHELL_TYPE_BASE_DASHBOARD);

static void expidus_shell_dashboard_draw(GtkWidget* widget, cairo_t* cr, gpointer data) {
  ExpidusShellDashboard* self = EXPIDUS_SHELL_DASHBOARD(widget);
  ExpidusShellDashboardPrivate* priv = expidus_shell_dashboard_get_instance_private(self);

  if (priv->supports_alpha) {
    GtkStyleContext* ctx = gtk_widget_get_style_context(widget);
    GdkRGBA color;
    gtk_style_context_get(ctx, gtk_widget_get_state_flags(widget), GTK_STYLE_PROPERTY_BACKGROUND_COLOR, &color, NULL);
    cairo_set_source_rgba(cr, color.red, color.green, color.blue, 0.4);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_paint(cr);
  }
}

static void expidus_shell_dashboard_screen_changed(GtkWidget* widget, GdkScreen* prev, gpointer data) {
  ExpidusShellDashboard* self = EXPIDUS_SHELL_DASHBOARD(widget);
  ExpidusShellDashboardPrivate* priv = expidus_shell_dashboard_get_instance_private(self);

  GdkScreen* screen = gtk_widget_get_screen(widget);
  GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
  if (visual == NULL) {
    visual = gdk_screen_get_system_visual(screen);
    priv->supports_alpha = FALSE;
  } else {
    priv->supports_alpha = TRUE;
  }
  gtk_widget_set_visual(widget, visual);
}

static void expidus_shell_dashboard_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_dashboard_parent_class)->constructed(obj);

  ExpidusShellDashboard* self = EXPIDUS_SHELL_DASHBOARD(obj);
  ExpidusShellDashboardPrivate* priv = expidus_shell_dashboard_get_instance_private(self);

  gtk_widget_set_app_paintable(GTK_WIDGET(self), TRUE);
  g_signal_connect(self, "draw", G_CALLBACK(expidus_shell_dashboard_draw), NULL);
  g_signal_connect(self, "screen-changed", G_CALLBACK(expidus_shell_dashboard_screen_changed), NULL);
  expidus_shell_dashboard_screen_changed(GTK_WIDGET(self), NULL, NULL);

  gint monitor_index;
  g_object_get(self, "monitor-index", &monitor_index, NULL);

	priv->proj = fl_dart_project_new();

	g_clear_pointer(&priv->proj->aot_library_path, g_free);
  g_clear_pointer(&priv->proj->assets_path, g_free);
  g_clear_pointer(&priv->proj->icu_data_path, g_free);

	priv->proj->aot_library_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "libapp.so", NULL);
	priv->proj->assets_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "assets", NULL);
	priv->proj->icu_data_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "icudtl.dat", NULL);

  char* argv[] = { g_strdup_printf("%d", monitor_index), "dashboard", NULL };
  fl_dart_project_set_dart_entrypoint_arguments(priv->proj, argv);

  priv->view = fl_view_new(priv->proj);
  gtk_widget_set_app_paintable(GTK_WIDGET(priv->view), TRUE);
  gtk_container_add(GTK_CONTAINER(self), GTK_WIDGET(priv->view));
}

static void expidus_shell_dashboard_dispose(GObject* obj) {
  ExpidusShellDashboard* self = EXPIDUS_SHELL_DASHBOARD(obj);
  ExpidusShellDashboardPrivate* priv = expidus_shell_dashboard_get_instance_private(self);

  g_clear_object(&priv->view);
  g_clear_object(&priv->proj);
  g_clear_object(&priv->channel_dart);
  g_clear_object(&priv->channel);

  G_OBJECT_CLASS(expidus_shell_dashboard_parent_class)->dispose(obj);
}

static void expidus_shell_dashboard_class_init(ExpidusShellDashboardClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->constructed = expidus_shell_dashboard_constructed;
  obj_class->dispose = expidus_shell_dashboard_dispose;
}

static void expidus_shell_dashboard_init(ExpidusShellDashboard* self) {}