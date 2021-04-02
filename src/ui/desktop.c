#include <expidus-shell/ui/desktop.h>
#include <expidus-shell/shell.h>
#define WNCK_I_KNOW_THIS_IS_UNSTABLE 1
#include <expidus-shell/utils.h>
#include <flutter_linux/flutter_linux.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>
#include <libwnck/libwnck.h>
#include <expidus-build.h>
#include <flutter.h>

typedef struct {
	FlDartProject* proj;
  FlView* view;
  FlMethodChannel* channel_dart;
  FlMethodChannel* channel;

  GSList* struts;

  WnckScreen* screen;
  gulong sig_win_changed;
  gulong sig_app_closed;
  gulong sig_app_opened;
  gulong sig_settings_changed;
} ExpidusShellDesktopPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDesktop, expidus_shell_desktop, EXPIDUS_SHELL_TYPE_BASE_DESKTOP);

static void expidus_shell_desktop_set_current_app_cb(GObject* obj, GAsyncResult* result, gpointer data) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(data);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  GError* error = NULL;
  FlMethodResponse* resp = fl_method_channel_invoke_method_finish(priv->channel_dart, result, &error);

  if (resp == NULL) {
    g_warning("Failed to call method: %s", error->message);
    return;
  }

  if (FL_IS_METHOD_ERROR_RESPONSE(resp)) {
    FlMethodErrorResponse* err_resp = FL_METHOD_ERROR_RESPONSE(resp);
    g_warning("Flutter response returned: %s - %s", fl_method_error_response_get_code(err_resp), fl_method_error_response_get_message(err_resp));
  } else if (FL_IS_METHOD_NOT_IMPLEMENTED_RESPONSE(resp)) {
  } else {
    if (fl_method_response_get_result(resp, &error) == NULL) {
      g_warning("Method returned error: %s", error->message);
      return;
    }
  }
}

static void expidus_shell_desktop_app_closed(WnckScreen* screen, WnckApplication* app, gpointer data) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(data);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  FlValue* args = fl_value_new_list();
  fl_value_append(args, fl_value_new_bool(FALSE));

  fl_method_channel_invoke_method(priv->channel_dart, "setCurrentApplication", args, NULL, expidus_shell_desktop_set_current_app_cb, self);
}

static gchar* cache_appicon(WnckApplication* app) {
  const gchar* name = wnck_application_get_name(app);
  if (wnck_application_get_icon(app) != NULL) {
    gchar* path = g_build_filename(g_get_tmp_dir(), g_strdup_printf("expidus-shell-appcache-%s-icon.png", name), NULL);
    GError* error = NULL;
    if (!gdk_pixbuf_save(wnck_application_get_icon(app), path, "png", &error, NULL)) {
      g_warning("Failed to cache icon: %s", error->message);
      return NULL;
    } else {
      return path;
    }
  }
  if (wnck_application_get_mini_icon(app) != NULL) {
    gchar* path = g_build_filename(g_get_tmp_dir(), g_strdup_printf("expidus-shell-appcache-%s-mini-icon.png", name), NULL);
    GError* error = NULL;
    if (!gdk_pixbuf_save(wnck_application_get_mini_icon(app), path, "png", &error, NULL)) {
      g_warning("Failed to cache icon: %s", error->message);
      return NULL;
    } else {
      return path;
    }
  }
  return NULL;
}

static void expidus_shell_desktop_settings_changed(GSettings* settings, char* key, gpointer data) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(data);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  if (g_str_has_prefix(key, "wallpaper-")) {
    gchar* wallpaper_uri = g_settings_get_string(settings, "wallpaper-uri");
    GDesktopBackgroundStyle wallpaper_opts = g_settings_get_enum(settings, "wallpaper-options");
    FlValue* args = fl_value_new_list();
    fl_value_append_take(args, fl_value_new_string(wallpaper_uri));
    fl_value_append_take(args, fl_value_new_int(wallpaper_opts));
    fl_method_channel_invoke_method(priv->channel_dart, "setWallpaper", args, NULL, expidus_shell_desktop_set_current_app_cb, self);
    g_debug("Updating wallpaper: %s %d", wallpaper_uri, wallpaper_opts);
  }
}

static void expidus_shell_desktop_method_handler(FlMethodChannel* channel, FlMethodCall* call, gpointer data) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(data);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  GError* error = NULL;
  if (!g_strcmp0(fl_method_call_get_name(call), "toggleActionButton")) {
    WnckWindow* win = wnck_screen_get_previously_active_window(priv->screen);
    if (win != NULL) {
      wnck_window_activate(win, 0);
      char* unique_bus_name = wnck_window_get_property_string(win, "_GTK_UNIQUE_BUS_NAME");
      char* menubar_obj_path = wnck_window_get_property_string(win, "_GTK_MENUBAR_OBJECT_PATH");

      GDBusConnection* session = g_bus_get_sync(G_BUS_TYPE_SESSION, NULL, NULL);

      GtkMenu* menu = NULL;
      if (unique_bus_name == NULL && menubar_obj_path == NULL) {
        menu = GTK_MENU(wnck_action_menu_new(win));
      } else {
        GDBusMenuModel* menu_model = g_dbus_menu_model_get(session, unique_bus_name, menubar_obj_path);
        menu = GTK_MENU(gtk_menu_new_from_model(G_MENU_MODEL(menu_model)));
      }

      GdkRectangle rect = { .x = 4, .y = 30, .width = 100, .height = 100 };
      gtk_menu_popup_at_rect(menu, gtk_widget_get_window(GTK_WIDGET(self)), &rect, GDK_GRAVITY_SOUTH, GDK_GRAVITY_SOUTH, NULL);
      g_object_unref(menu);
    } else {
      ExpidusShell* shell;
      g_object_get(self, "shell", &shell, NULL);
      g_assert(shell);
      expidus_shell_toggle_dashboard(shell, EXPIDUS_SHELL_DASHBOARD_START_MODE_NONE);
    }

    if (!fl_method_call_respond_success(call, fl_value_new_null(), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "syncWallpaper")) {
    ExpidusShell* shell;
    g_object_get(self, "shell", &shell, NULL);
    g_assert(shell);

    GSettings* settings;
	  g_object_get(shell, "settings", &settings, NULL);
    g_assert(settings);

    expidus_shell_desktop_settings_changed(settings, "wallpaper-", self);

    if (!fl_method_call_respond_success(call, fl_value_new_null(), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "keepFocus")) {
    WnckWindow* win = wnck_screen_get_previously_active_window(priv->screen);
    if (win != NULL) wnck_window_activate(win, 0);
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

static void expidus_shell_desktop_app_opened(WnckScreen* screen, WnckApplication* app, gpointer data) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(data);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  FlValue* args = fl_value_new_list();
  const gchar* name = wnck_application_get_name(app);
  if (!g_strcmp0(name, "expidus-shell.bin")) {
    fl_value_append(args, fl_value_new_bool(FALSE));
  } else {
    fl_value_append(args, fl_value_new_bool(TRUE));
    fl_value_append(args, fl_value_new_string(name));
    const gchar* icon_name = wnck_application_get_icon_name(app);
    if (icon_name != NULL) {
      GtkIconTheme* icon_theme = gtk_icon_theme_get_default();
      GtkIconInfo* icon_info = gtk_icon_theme_lookup_icon(icon_theme, icon_name, 32, GTK_ICON_LOOKUP_NO_SVG);
      if (icon_info != NULL) {
        g_debug("Loaded icon info (non-svg image): %s", icon_name);
        fl_value_append(args, fl_value_new_string(gtk_icon_info_get_filename(icon_info)));
        g_object_unref(icon_info);
      } else {
        gchar* icon_path = cache_appicon(app);
        if (icon_path != NULL) fl_value_append(args, fl_value_new_string(icon_path));
      }
    } else {
      gchar* icon_path = cache_appicon(app);
      if (icon_path != NULL) fl_value_append(args, fl_value_new_string(icon_path));
    }
  }

  fl_method_channel_invoke_method(priv->channel_dart, "setCurrentApplication", args, NULL, expidus_shell_desktop_set_current_app_cb, self);
}

static void expidus_shell_desktop_win_changed(WnckScreen* screen, WnckWindow* prev_win, gpointer data) {
  WnckWindow* win = wnck_screen_get_active_window(screen);
  WnckApplication* app = win != NULL ? wnck_window_get_application(win) : NULL;
  if (win == NULL) {
    expidus_shell_desktop_app_closed(screen, NULL, data);
  } else {
    expidus_shell_desktop_app_opened(screen, app, data);
  }
}

static void expidus_shell_desktop_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->constructed(obj);

  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  GtkWindow* win = GTK_WINDOW(self);

  ExpidusShell* shell;
  gint monitor_index;
  g_object_get(self, "shell", &shell, "monitor-index", &monitor_index, NULL);
  g_assert(shell);

	MetaPlugin* plugin;
  GSettings* settings;
	g_object_get(shell, "plugin", &plugin, "settings", &settings, NULL);
	g_assert(plugin);
  g_assert(settings);

	MetaDisplay* disp = meta_plugin_get_display(plugin);
  MetaRectangle rect;
  meta_display_get_monitor_geometry(disp, monitor_index, &rect);

	priv->proj = fl_dart_project_new();

	g_clear_pointer(&priv->proj->aot_library_path, g_free);
  g_clear_pointer(&priv->proj->assets_path, g_free);
  g_clear_pointer(&priv->proj->icu_data_path, g_free);

	priv->proj->aot_library_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "libapp.so", NULL);
	priv->proj->assets_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "assets", NULL);
	priv->proj->icu_data_path = g_build_filename(EXPIDUS_SHELL_LIBDIR, "icudtl.dat", NULL);

  char* argv[] = { g_strdup_printf("%d", monitor_index), "desktop", NULL };
  fl_dart_project_set_dart_entrypoint_arguments(priv->proj, argv);

  priv->view = fl_view_new(priv->proj);

  gtk_container_add(GTK_CONTAINER(win), GTK_WIDGET(priv->view));

  MetaStrut* strut = g_slice_new0(MetaStrut);
  g_assert(strut);
  strut->side = META_SIDE_TOP;
  strut->rect = meta_rect(rect.x, rect.y, rect.height, 30);
  priv->struts = g_slist_append(priv->struts, strut);

  FlEngine* engine = fl_view_get_engine(priv->view);
  FlBinaryMessenger* binmsg = fl_engine_get_binary_messenger(engine);
  priv->channel_dart = fl_method_channel_new(binmsg, "com.expidus.shell/desktop.dart", FL_METHOD_CODEC(fl_standard_method_codec_new()));

  priv->channel = fl_method_channel_new(binmsg, "com.expidus.shell/desktop", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(priv->channel, expidus_shell_desktop_method_handler, self, NULL);

  priv->screen = wnck_screen_get_default();
  g_assert(priv->screen);
  priv->sig_win_changed = g_signal_connect(priv->screen, "active-window-changed", G_CALLBACK(expidus_shell_desktop_win_changed), self);
  priv->sig_app_closed = g_signal_connect(priv->screen, "application-closed", G_CALLBACK(expidus_shell_desktop_app_closed), self);
  priv->sig_app_opened = g_signal_connect(priv->screen, "application-opened", G_CALLBACK(expidus_shell_desktop_app_opened), self);
  priv->sig_settings_changed = g_signal_connect(settings, "changed", G_CALLBACK(expidus_shell_desktop_settings_changed), self);
}

static void expidus_shell_desktop_dispose(GObject* obj) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  g_clear_object(&priv->view);
  g_clear_object(&priv->proj);
  g_clear_object(&priv->channel_dart);
  g_clear_object(&priv->channel);

  if (priv->sig_app_closed > 0) {
    g_signal_handler_disconnect(priv->screen, priv->sig_app_closed);
    priv->sig_app_closed = 0;
  }

  if (priv->sig_app_opened > 0) {
    g_signal_handler_disconnect(priv->screen, priv->sig_app_opened);
    priv->sig_app_opened = 0;
  }

  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->dispose(obj);
}

static GSList* expidus_shell_desktop_get_struts(ExpidusShellBaseDesktop* base_desktop) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(base_desktop);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);
  return priv->struts;
}

static void expidus_shell_desktop_class_init(ExpidusShellDesktopClass* klass) {
	GObjectClass* obj_class = G_OBJECT_CLASS(klass);
  ExpidusShellBaseDesktopClass* base_desktop_class = EXPIDUS_SHELL_BASE_DESKTOP_CLASS(klass);

  obj_class->constructed = expidus_shell_desktop_constructed;
  obj_class->dispose = expidus_shell_desktop_dispose;

  base_desktop_class->get_struts = expidus_shell_desktop_get_struts;
}

static void expidus_shell_desktop_init(ExpidusShellDesktop* self) {}