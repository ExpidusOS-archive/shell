#pragma once

#include <glib-object.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_OVERLAY expidus_shell_overlay_get_type()
G_DECLARE_FINAL_TYPE(ExpidusShellOverlay, expidus_shell_overlay, EXPIDUS_SHELL, OVERLAY, GtkWindow);

struct _ExpidusShellOverlay {
  GtkWindow parent_instance;
};

GSList* expidus_shell_overlay_get_struts(ExpidusShellOverlay* self);

G_END_DECLS