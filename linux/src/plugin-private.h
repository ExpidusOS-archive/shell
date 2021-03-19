#pragma once

#include <glib.h>
#include <clutter/clutter.h>
#include <gio/gio.h>

struct _ExpidusShellPluginPrivate {
  ClutterActor* bg_group;
  GSettings* settings;
  GSList* desktops;
};