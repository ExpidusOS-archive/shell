#include <expidus-shell/desktop.h>
#include <expidus-shell/flutter.h>
#include <expidus-shell/global-messanger.h>
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
  gboolean alpha_supported;
} ExpidusShellOverlayPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellOverlay, expidus_shell_overlay, GTK_TYPE_WINDOW);

enum {
  PROP_0,
  PROP_PLUGIN,
  PROP_MONITOR_INDEX,
  N_PROPS
};

static GParamSpec* obj_props[N_PROPS] = { NULL };

static void strut_free(gpointer data) {
  g_slice_free(MetaStrut, data);
}

static void expidus_shell_overlay_handle_message(FlMethodChannel* channel, FlMethodCall* call, gpointer data) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(data);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  GError* error = NULL;
  g_debug("Receiving method call: %s", fl_method_call_get_name(call));
  if (!g_strcmp0(fl_method_call_get_name(call), "onDrawerChanged")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_BOOL) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting boolean", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    MetaDisplay* disp = meta_plugin_get_display(META_PLUGIN(priv->plugin));
    MetaRectangle rect;
    meta_display_get_monitor_geometry(disp, priv->monitor_index, &rect);
    cairo_rectangle_int_t crrect = {
      .x = 0,
      .y = 0,
      .width = 80,
      .height = rect.height
    };

    cairo_region_t* region = cairo_region_create_rectangle(&crrect);
    gdk_window_input_shape_combine_region(gtk_widget_get_window(GTK_WIDGET(self)), region, 0, 0);
    cairo_region_destroy(region);

    if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null())), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "onDashboard")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_BOOL) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting boolean", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    MetaDisplay* disp = meta_plugin_get_display(META_PLUGIN(priv->plugin));
    MetaRectangle rect;
    meta_display_get_monitor_geometry(disp, priv->monitor_index, &rect);
    cairo_rectangle_int_t crrect = {
      .x = 0,
      .y = 0,
      .width = rect.width,
      .height = rect.height
    };

    cairo_region_t* region = cairo_region_create_rectangle(&crrect);
    gdk_window_input_shape_combine_region(gtk_widget_get_window(GTK_WIDGET(self)), region, 0, 0);
    cairo_region_destroy(region);

    if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null())), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "onEndDrawerChanged")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_BOOL) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting boolean", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    MetaDisplay* disp = meta_plugin_get_display(META_PLUGIN(priv->plugin));
    MetaRectangle rect;
    meta_display_get_monitor_geometry(disp, priv->monitor_index, &rect);
    cairo_rectangle_int_t crrect = {
      .x = rect.width - 300,
      .y = 0,
      .width = 300,
      .height = rect.height
    };

    cairo_region_t* region = cairo_region_create_rectangle(&crrect);
    gdk_window_input_shape_combine_region(gtk_widget_get_window(GTK_WIDGET(self)), region, 0, 0);
    cairo_region_destroy(region);

    if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null())), &error)) {
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

static void expidus_shell_overlay_screen_changed(GtkWidget* widget, GdkScreen* old, gpointer data) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(widget);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  GdkScreen* screen = gtk_widget_get_screen(widget);
  GdkVisual* visual = gdk_screen_get_rgba_visual(screen);

  if (!visual && !gdk_screen_is_composited(screen)) {
    visual = gdk_screen_get_system_visual(screen);
    g_warning("Screen does not support alpha channels.");
    priv->alpha_supported = FALSE;
  } else {
    priv->alpha_supported = TRUE;
  }

  gtk_widget_set_visual(widget, visual);
}

static gboolean expidus_shell_overlay_draw(GtkWidget* widget, cairo_t* cr, gpointer data) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(data);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  g_assert(priv->alpha_supported);
  cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 0.0);
  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
  cairo_paint(cr);
  cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
  return FALSE;
}

static void expidus_shell_overlay_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

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

static void expidus_shell_overlay_get_property(GObject* obj, guint prop_id, GValue* value, GParamSpec* pspec) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  switch (prop_id) {
    case PROP_PLUGIN:
      g_value_set_object(value, priv->plugin);
      break;
    case PROP_MONITOR_INDEX:
      g_value_set_uint(value, priv->monitor_index);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
      break;
  }
}

static void expidus_shell_overlay_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_overlay_parent_class)->constructed(obj);

  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

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
  g_signal_connect(win, "draw", G_CALLBACK(expidus_shell_overlay_draw), self);

  MetaDisplay* disp = meta_plugin_get_display(META_PLUGIN(priv->plugin));
  MetaRectangle rect;
  meta_display_get_monitor_geometry(disp, priv->monitor_index, &rect);
  gtk_window_move(win, rect.x, rect.y);
  gtk_window_set_default_size(win, rect.width, rect.height);
  gtk_window_set_resizable(win, FALSE);
  gtk_widget_set_size_request(GTK_WIDGET(win), rect.width, rect.height);

  priv->proj = fl_dart_project_new();
  char* argv[] = { g_strdup_printf("%d", priv->monitor_index), "overlay",
#ifdef DEBUG
    "--observe",
#endif
    NULL };
  fl_dart_project_set_dart_entrypoint_arguments(priv->proj, argv);

  priv->view = fl_view_new(priv->proj);
  gtk_widget_set_app_paintable(GTK_WIDGET(priv->view), TRUE);

  FlEngine* fl_engine = fl_view_get_engine(priv->view);
  FlBinaryMessenger* binmsg = fl_engine_get_binary_messenger(fl_engine);
  FlMethodChannel* channel = fl_method_channel_new(binmsg, "com.expidus.shell/overlay", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(channel, expidus_shell_overlay_handle_message, self, NULL);
  expidus_shell_messanger_init(priv->plugin, fl_engine);

  gtk_widget_show(GTK_WIDGET(priv->view));
  gtk_container_add(GTK_CONTAINER(win), GTK_WIDGET(priv->view));
  flutter_register_plugins(FL_PLUGIN_REGISTRY(priv->view));

  expidus_shell_overlay_screen_changed(GTK_WIDGET(win), NULL, NULL);
  gtk_widget_show_all(GTK_WIDGET(win));
  gdk_window_input_shape_combine_region(gtk_widget_get_window(GTK_WIDGET(win)), cairo_region_create(), 0, 0);

  cairo_rectangle_int_t crrect[] = {
    {
      .x = 0,
      .y = 0,
      .width = 25,
      .height = rect.height
    },
    {
      .x = rect.width - 25,
      .y = 0,
      .width = 25,
      .height = rect.height
    }
  };
  cairo_region_t* region = cairo_region_create_rectangles(crrect, 2);
  gdk_window_input_shape_combine_region(gtk_widget_get_window(GTK_WIDGET(win)), region, 0, 0);
  cairo_region_destroy(region);
}

static void expidus_shell_overlay_dispose(GObject* obj) {
  ExpidusShellOverlay* self = EXPIDUS_SHELL_OVERLAY(obj);
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);

  g_clear_object(&priv->view);
  g_clear_object(&priv->proj);
  g_clear_slist(&priv->struts, strut_free);

  G_OBJECT_CLASS(expidus_shell_overlay_parent_class)->dispose(obj);
}

static void expidus_shell_overlay_class_init(ExpidusShellOverlayClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->set_property = expidus_shell_overlay_set_property;
  obj_class->get_property = expidus_shell_overlay_get_property;
  obj_class->constructed = expidus_shell_overlay_constructed;
  obj_class->dispose = expidus_shell_overlay_dispose;

  obj_props[PROP_PLUGIN] = g_param_spec_object("plugin", "Plugin", "The Mutter Plugin (ExpidusOS Shell) instance to connect to.", EXPIDUS_SHELL_TYPE_PLUGIN, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  obj_props[PROP_MONITOR_INDEX] = g_param_spec_uint("monitor-index", "Monitor Index", "The monitor's index to render and use.", 0, 255, 0, G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE);
  g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_overlay_init(ExpidusShellOverlay* self) {
}

GSList* expidus_shell_overlay_get_struts(ExpidusShellOverlay* self) {
  ExpidusShellOverlayPrivate* priv = expidus_shell_overlay_get_instance_private(self);
  return priv->struts;
}