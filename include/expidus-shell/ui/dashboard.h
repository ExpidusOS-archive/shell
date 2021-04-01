#pragma once

#include <glib-object.h>
#include <expidus-shell/base-dashboard.h>

G_BEGIN_DECLS

#define EXPIDUS_SHELL_TYPE_DASHBOARD expidus_shell_dashboard_get_type()
G_DECLARE_DERIVABLE_TYPE(ExpidusShellDashboard, expidus_shell_dashboard, EXPIDUS_SHELL, DASHBOARD, ExpidusShellBaseDashboard);

struct _ExpidusShellDashboardClass {
  ExpidusShellBaseDashboardClass parent_class;
};

G_END_DECLS