#pragma once

#include <glib-object.h>
#include <expidus-shell/base-dashboard.h>

G_BEGIN_DECLS

#define EXPIDUS_TYPE_SHELL expidus_shell_get_type()
G_DECLARE_FINAL_TYPE(ExpidusShell, expidus_shell, EXPIDUS, SHELL, GObject);

struct _ExpidusShell {
	GObject parent_instance;
};

GList* expidus_shell_get_desktops(ExpidusShell* self);
GSettings* expidus_shell_get_settings(ExpidusShell* self);
void expidus_shell_sync_desktops(ExpidusShell* self);
void expidus_shell_toggle_dashboard(ExpidusShell* self, ExpidusShellDashboardStartMode start_mode);
void expidus_shell_show_dashboard(ExpidusShell* self, ExpidusShellDashboardStartMode start_mode);
void expidus_shell_hide_dashboard(ExpidusShell* self);

G_END_DECLS