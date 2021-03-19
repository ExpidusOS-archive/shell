#include <expidus-shell/global-messanger.h>
#include <gio/gio.h>
#include <gio/gdesktopappinfo.h>
#include "plugin-private.h"

static FlValue* glib_to_flutter(GVariant* variant) {
  FlValue* value = NULL;
  if (g_variant_is_of_type(variant, G_VARIANT_TYPE_BOOLEAN)) {
    value = fl_value_new_bool(g_variant_get_boolean(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_INT16)) {
    value = fl_value_new_int(g_variant_get_int16(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_INT32)) {
    value = fl_value_new_int(g_variant_get_int32(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_INT64)) {
    value = fl_value_new_int(g_variant_get_int64(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_UINT16)) {
    value = fl_value_new_int(g_variant_get_uint16(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_UINT32)) {
    value = fl_value_new_int(g_variant_get_uint32(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_UINT64)) {
    value = fl_value_new_int(g_variant_get_uint64(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_DOUBLE)) {
    value = fl_value_new_float(g_variant_get_double(variant));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_STRING)) {
    value = fl_value_new_string(g_variant_get_string(variant, NULL));
  } else if (g_variant_is_of_type(variant, G_VARIANT_TYPE_ARRAY)) {
    value = fl_value_new_list();
    size_t len = g_variant_n_children(variant);
    for (size_t i = 0; i < len; i++) {
      fl_value_append_take(value, glib_to_flutter(g_variant_get_child_value(variant, i)));
    }
  }
  return value;
}

static GVariant* flutter_to_glib(FlValue* value) {
  GVariant* variant = NULL;
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_BOOL:
      variant = g_variant_new_boolean(fl_value_get_bool(value));
      break;
    case FL_VALUE_TYPE_INT:
      variant = g_variant_new_int64(fl_value_get_int(value));
      break;
    case FL_VALUE_TYPE_FLOAT:
      variant = g_variant_new_double(fl_value_get_float(value));
      break;
    case FL_VALUE_TYPE_STRING:
      variant = g_variant_new_string(fl_value_get_string(value));
      break;
    case FL_VALUE_TYPE_UINT8_LIST:
      variant = g_variant_new("ay", fl_value_get_uint8_list(value));
      break;
    case FL_VALUE_TYPE_INT32_LIST:
      variant = g_variant_new("ai", fl_value_get_int32_list(value));
      break;
    case FL_VALUE_TYPE_INT64_LIST:
      variant = g_variant_new("ax", fl_value_get_int64_list(value));
      break;
    case FL_VALUE_TYPE_FLOAT_LIST:
      variant = g_variant_new("ad", fl_value_get_float_list(value));
      break;
    case FL_VALUE_TYPE_LIST:
      {
        GVariantBuilder* builder = g_variant_builder_new(G_VARIANT_TYPE_ARRAY);
        size_t len = fl_value_get_length(value);
        for (size_t i = 0; i < len; i++) {
          g_variant_builder_add_value(builder, flutter_to_glib(fl_value_get_list_value(value, i)));
        }
        variant = g_variant_builder_end(builder);
        g_variant_builder_unref(builder);
      }
      break;
    default: return NULL;
  }
  return variant;
}

static void applications_handler(FlMethodChannel* channel, FlMethodCall* call, gpointer data) {
  //ExpidusShellPlugin* plugin = EXPIDUS_SHELL_PLUGIN(data);
  //ExpidusShellPluginPrivate* priv = plugin->priv;

  GError* error = NULL;
  if (!g_strcmp0(fl_method_call_get_name(call), "isValid")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_STRING) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting string", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    GDesktopAppInfo* info = g_desktop_app_info_new(fl_value_get_string(res));
    if (info == NULL) info = g_desktop_app_info_new(g_strdup_printf("%s.desktop", fl_value_get_string(res)));
    if (!fl_method_call_respond_success(call, fl_value_new_bool(info != NULL), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
    if (info != NULL) g_object_unref(info);
  } else if (!g_strcmp0(fl_method_call_get_name(call), "getAllApplicationsByID")) {
    GList* apps = g_app_info_get_all();
    FlValue* resp = fl_value_new_list();
    for (GList* item = apps; item != NULL; item = g_list_next(item)) {
      GAppInfo* app = G_APP_INFO(item->data);
      if (!app) continue;
      if (!g_app_info_should_show(app)) continue;
      const gchar* id = g_app_info_get_id(app);
      if (id == NULL) continue;
      fl_value_append_take(resp, fl_value_new_string(id));
    }
    g_clear_list(&apps, g_object_unref);
    if (!fl_method_call_respond_success(call, resp, &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "getValues")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_STRING) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting string", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    GDesktopAppInfo* info = g_desktop_app_info_new(fl_value_get_string(res));
    if (info == NULL) info = g_desktop_app_info_new(g_strdup_printf("%s.desktop", fl_value_get_string(res)));

    if (info == NULL) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("app.invalid", "Invalid application", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    GIcon* icon = g_app_info_get_icon(G_APP_INFO(info));
    gchar* icon_path = NULL;
    if (G_IS_FILE_ICON(icon)) icon_path = g_file_get_path(g_file_icon_get_file(G_FILE_ICON(icon)));
    else {
      GtkIconTheme* icon_theme = gtk_icon_theme_get_default();
      GtkIconInfo* icon_info = gtk_icon_theme_lookup_by_gicon(icon_theme, icon, 32, GTK_ICON_LOOKUP_NO_SVG);
      g_assert(icon_info);
      icon_path = (gchar*)gtk_icon_info_get_filename(icon_info);
    }

    FlValue* resp = fl_value_new_list();
    fl_value_append_take(resp, fl_value_new_string(icon_path));
    fl_value_append_take(resp, fl_value_new_string(g_app_info_get_display_name(G_APP_INFO(info))));
    if (!fl_method_call_respond_success(call, resp, &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "launch")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_STRING) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting string", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    GDesktopAppInfo* info = g_desktop_app_info_new(fl_value_get_string(res));
    if (info == NULL) info = g_desktop_app_info_new(g_strdup_printf("%s.desktop", fl_value_get_string(res)));

    if (info == NULL) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("app.invalid", "Invalid application", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    if (!g_app_info_launch(G_APP_INFO(info), NULL, NULL, &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }

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

static void settings_handler(FlMethodChannel* channel, FlMethodCall* call, gpointer data) {
  ExpidusShellPlugin* plugin = EXPIDUS_SHELL_PLUGIN(data);
  ExpidusShellPluginPrivate* priv = plugin->priv;

  GError* error = NULL;
  if (!g_strcmp0(fl_method_call_get_name(call), "get")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_STRING) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting string", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    const char* name = fl_value_get_string(res);
    if (!fl_method_call_respond_success(call, glib_to_flutter(g_settings_get_value(priv->settings, name)), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  } else if (!g_strcmp0(fl_method_call_get_name(call), "set")) {
    FlValue* res = fl_method_call_get_args(call);
    if (fl_value_get_type(res) != FL_VALUE_TYPE_LIST) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting list", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    if (fl_value_get_length(res) != 2) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.wrongsize", "Invalid argument, array is not the right size", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    if (fl_value_get_type(fl_value_get_list_value(res, 0)) != FL_VALUE_TYPE_STRING) {
      if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Invalid argument, expecting first argument to be a string", NULL)), &error)) {
        g_error("Failed to respond to call: %s", error->message);
        g_clear_error(&error);
      }
      return;
    }

    const char* name = fl_value_get_string(fl_value_get_list_value(res, 0));
    FlValue* val = fl_value_get_list_value(res, 0);
    switch (fl_value_get_type(val)) {
      case FL_VALUE_TYPE_NULL:
        g_settings_reset(priv->settings, name);
        break;
      default:
        {
          GVariant* variant = flutter_to_glib(val);
          if (variant == NULL) {
            if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_error_response_new("args.invalid", "Second argument type is not supported", NULL)), &error)) {
              g_error("Failed to respond to call: %s", error->message);
              g_clear_error(&error);
            }
            return;
          }

          g_settings_set_value(priv->settings, name, variant);
          g_variant_unref(variant);
        }
        return;
    }
  } else {
    if (!fl_method_call_respond(call, FL_METHOD_RESPONSE(fl_method_not_implemented_response_new()), &error)) {
      g_error("Failed to respond to call: %s", error->message);
      g_clear_error(&error);
    }
  }
}

void expidus_shell_messanger_init_applications(ExpidusShellPlugin* plugin, FlEngine* engine) {
  FlBinaryMessenger* binmsg = fl_engine_get_binary_messenger(engine);
  FlMethodChannel* channel = fl_method_channel_new(binmsg, "com.expidus.shell/applications", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(channel, applications_handler, plugin, NULL);
}

void expidus_shell_messanger_init_settings(ExpidusShellPlugin* plugin, FlEngine* engine) {
  FlBinaryMessenger* binmsg = fl_engine_get_binary_messenger(engine);
  FlMethodChannel* channel = fl_method_channel_new(binmsg, "com.expidus.shell/settings", FL_METHOD_CODEC(fl_standard_method_codec_new()));
  fl_method_channel_set_method_call_handler(channel, settings_handler, plugin, NULL);
}

void expidus_shell_messanger_init(ExpidusShellPlugin* plugin, FlEngine* engine) {
  expidus_shell_messanger_init_applications(plugin, engine);
  expidus_shell_messanger_init_settings(plugin, engine);
}