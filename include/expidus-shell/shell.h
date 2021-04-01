#pragma once

#include <glib-object.h>

G_BEGIN_DECLS

#define EXPIDUS_TYPE_SHELL expidus_shell_get_type()
G_DECLARE_FINAL_TYPE(ExpidusShell, expidus_shell, EXPIDUS, SHELL, GObject);

struct _ExpidusShell {
	GObject parent_instance;
};

GList* expidus_shell_get_desktops(ExpidusShell* shell);
void expidus_shell_sync_desktops(ExpidusShell* self);

G_END_DECLS
