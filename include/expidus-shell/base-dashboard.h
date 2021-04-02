#pragma once

#include <glib-object.h>
#include <gtk/gtk.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_BASE_DASHBOARD expidus_shell_base_dashboard_get_type()
G_DECLARE_DERIVABLE_TYPE(ExpidusShellBaseDashboard, expidus_shell_base_dashboard, EXPIDUS_SHELL, BASE_DASHBOARD, GtkWindow);

struct _ExpidusShellBaseDashboardClass {
  GtkWindowClass parent_class;
};

typedef enum {
  EXPIDUS_SHELL_DASHBOARD_START_MODE_NONE = 0,
  EXPIDUS_SHELL_DASHBOARD_START_MODE_LEFT_DRAWER,
  EXPIDUS_SHELL_DASHBOARD_START_MODE_RIGHT_DRAWER
} ExpidusShellDashboardStartMode;

G_END_DECLS