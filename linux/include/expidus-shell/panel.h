#pragma once

#include <glib-object.h>
#include <clutter/clutter.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_PANEL expidus_shell_panel_get_type()
G_DECLARE_FINAL_TYPE(ExpidusShellPanel, expidus_shell_panel, EXPIDUS_SHELL, PANEL, ClutterCanvas);

struct _ExpidusShellPanel {
  ClutterCanvas parent_instance;
};

G_END_DECLS