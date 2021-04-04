#include <expidus-shell/ui/dashboard.h>
#include <expidus-shell/shell.h>
#include <expidus-build.h>
#include <flutter.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>

typedef struct {
	FlDartProject* proj;
  FlView* view;
  FlMethodChannel* channel_dart;
  FlMethodChannel* channel;

  gboolean supports_alpha;
  gchar* background_path;
} ExpidusShellDashboardPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDashboard, expidus_shell_dashboard, EXPIDUS_SHELL_TYPE_BASE_DASHBOARD);

static void expidus_shell_dashboard_method_handler(FlMethodChannel* channel, FlMethodCall* call, gpointer data) {
  ExpidusShellDashboard* self = EXPIDUS_SHELL_DASHBOARD(data);
  GError* error = NULL;
  if (!g_strcmp0(fl_method_call_get_name(call), "hideDashboard")) {
    ExpidusShell* shell;
    g_object_get(self, "shell", &shell, NULL);
    g_assert(shell);

    expidus_shell_hide_dashboard(shell);
    if (!fl_method_call_respond_success(call, fl_value_new_null(), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else {
    if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_not_implemented_response_new()), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  }
}

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

  ExpidusShell* shell;
  gint monitor_index;
  ExpidusShellDashboardStartMode start_mode;
  g_object_get(self, "shell", &shell, "monitor-index", &monitor_index, "start-mode", &start_mode, NULL);

	MetaPlugin* plugin;
	g_object_get(shell, "plugin", &plugin, NULL);
	g_assert(plugin);

	MetaDisplay* disp = meta_plugin_get_display(plugin);
  MetaRectangle rect;
  meta_display_get_monitor_geometry(disp, monitor_index, &rect);

  priv->background_path = g_build_filename(g_get_tmp_dir(), g_strdup_printf("expidus-shell-dashboard-%d-%d.png", getpid(), monitor_index), NULL);
  GdkPixbuf* screenshot = gdk_pixbuf_get_from_window(gdk_get_default_root_window(), rect.x, rect.y, rect.width, rect.height);
  GError* error = NULL;
  if (!gdk_pixbuf_save(screenshot, priv->background_path, "png", &error, NULL)) {
    g_object_unref(screenshot);
    g_critical("Failed to save screenshot to %s: %s", priv->background_path, error->message);
    g_clear_error(&error);
    exit(EXIT_FAILURE);
  }
  g_object_unref(screenshot);

	priv->proj = fl_dart_project_new();

	g_clear_pointer(&priv->proj->aot_library_path, g_free);
  g_clear_pointer(&priv->proj->assets_path, g_free);
  g_clear_pointer(&priv->proj->icu_data_path, g_free);

	priv->proj->aot_library_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "libapp.so", NULL);
	priv->proj->assets_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "assets", NULL);
	priv->proj->icu_data_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "icudtl.dat", NULL);

  char* argv[] = { g_strdup_printf("%d", monitor_index), "dashboard", priv->background_path, g_strdup_printf("%d", start_mode), NULL };
  fl_dart_project_set_dart_entrypoint_arguments(priv->proj, argv);

  priv->view = fl_view_new(priv->proj);
  FlEngine* engine = fl_view_get_engine(priv->view);
  FlBinaryMessenger* binmsg = fl_engine_get_binary_messenger(engine);
  priv->channel = fl_method_channel_new(binmsg, "com.expidus.shell/dashboard", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(priv->channel, expidus_shell_dashboard_method_handler, self, NULL);

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
  if (priv->background_path) remove(priv->background_path);
  g_clear_pointer(&priv->background_path, g_free);

  G_OBJECT_CLASS(expidus_shell_dashboard_parent_class)->dispose(obj);
}

static void expidus_shell_dashboard_class_init(ExpidusShellDashboardClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->constructed = expidus_shell_dashboard_constructed;
  obj_class->dispose = expidus_shell_dashboard_dispose;
}

static void expidus_shell_dashboard_init(ExpidusShellDashboard* self) {}