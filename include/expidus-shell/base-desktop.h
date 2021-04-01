#pragma once

#include <glib-object.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_BASE_DESKTOP expidus_shell_base_desktop_get_type()
G_DECLARE_DERIVABLE_TYPE(ExpidusShellBaseDesktop, expidus_shell_base_desktop, EXPIDUS_SHELL, BASE_DESKTOP, GtkWindow);

struct _ExpidusShellBaseDesktopClass {
  GtkWindowClass parent_class;

  GSList* (*get_struts)(ExpidusShellBaseDesktop* self);
};

GSList* expidus_shell_base_desktop_get_struts(ExpidusShellBaseDesktop* self);

G_END_DECLS