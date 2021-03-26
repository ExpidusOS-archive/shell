#pragma once

#include <glib-object.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_DESKTOP expidus_shell_desktop_get_type()
G_DECLARE_DERIVABLE_TYPE(ExpidusShellDesktop, expidus_shell_desktop, EXPIDUS_SHELL, DESKTOP, GtkWindow);

struct _ExpidusShellDesktopClass {
  GtkWindowClass parent_class;
};

G_END_DECLS