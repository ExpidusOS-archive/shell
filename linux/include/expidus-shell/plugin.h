#pragma once

#include <glib-object.h>
#include <meta/meta-plugin.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_PLUGIN expidus_shell_plugin_get_type()
G_DECLARE_FINAL_TYPE(ExpidusShellPlugin, expidus_shell_plugin, EXPIDUS_SHELL, PLUGIN, MetaPlugin);

typedef struct _ExpidusShellPluginPrivate ExpidusShellPluginPrivate;

struct _ExpidusShellPlugin {
  MetaPlugin parent_instance;
  ExpidusShellPluginPrivate* priv;
};

void expidus_shell_plugin_update_struts(ExpidusShellPlugin* self, GSList* struts);

G_END_DECLS