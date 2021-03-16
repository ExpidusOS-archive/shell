#pragma once

#include <glib-object.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_DESKTOP expidus_shell_desktop_get_type()
G_DECLARE_FINAL_TYPE(ExpidusShellDesktop, expidus_shell_desktop, EXPIDUS_SHELL, DESKTOP, GtkWindow);

struct _ExpidusShellDesktop {
  GtkWindow parent_instance;
};

G_END_DECLS