#include <expidus-shell/ui/dashboard.h>
#include <expidus-shell/ui/desktop.h>
#include <expidus-shell/base-dashboard.h>
#include <expidus-shell/base-desktop.h>
#include <expidus-shell/overlay.h>
#include <expidus-shell/shell.h>
#include <meta/display.h>
#include <meta/meta-plugin.h>
#include <meta/meta-monitor-manager.h>

typedef struct {
	GList* desktops;
	GList* dashboards;
	GList* overlays;

	MetaPlugin* plugin;
	GSettings* settings;

	GType desktop_type;
	GType dashboard_type;
	GType lockscreen_type;
	GType notification_type;
} ExpidusShellPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShell, expidus_shell, G_TYPE_OBJECT);

enum {
	PROP_0,
	PROP_PLUGIN,
	PROP_SETTINGS,
	N_PROPS,

	SIG_0 = 0,
	SIG_DESKTOP_CREATED,
	SIG_DESKTOP_DESTROYED,
	SIG_SERVICE_LOAD,
	SIG_SERVICE_UNLOAD,
	N_SIGS,
};

static GParamSpec* obj_props[N_PROPS] = { NULL };
//static guint obj_signals[N_SIGS] = {};

static void expidus_shell_set_property(GObject* obj, guint prop_id, const GValue* value, GParamSpec* pspec) {
	ExpidusShell* self = EXPIDUS_SHELL(obj);
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);

	switch (prop_id) {
		case PROP_PLUGIN:
			priv->plugin = g_value_get_object(value);
			break;
		default:
			G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
			break;
	}
}

static void expidus_shell_get_property(GObject* obj, guint prop_id, GValue* value, GParamSpec* pspec) {
	ExpidusShell* self = EXPIDUS_SHELL(obj);
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);

	switch (prop_id) {
		case PROP_PLUGIN:
			g_value_set_object(value, priv->plugin);
			break;
		case PROP_SETTINGS:
			g_value_set_object(value, priv->settings);
			break;
		default:
			G_OBJECT_WARN_INVALID_PROPERTY_ID(obj, prop_id, pspec);
			break;
	}
}

static void expidus_shell_constructed(GObject* obj) {
	G_OBJECT_CLASS(expidus_shell_parent_class)->constructed(obj);

	ExpidusShell* self = EXPIDUS_SHELL(obj);
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);

	priv->settings = g_settings_new("com.expidus.shell");

	priv->desktop_type = EXPIDUS_SHELL_TYPE_DESKTOP;
	priv->dashboard_type = EXPIDUS_SHELL_TYPE_DASHBOARD;

	priv->desktops = NULL;
	priv->dashboards = NULL;
}

static void expidus_shell_finalize(GObject* obj) {
	ExpidusShell* self = EXPIDUS_SHELL(obj);
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);

	g_clear_object(&priv->settings);
	g_clear_list(&priv->desktops, g_object_unref);
	g_clear_list(&priv->dashboards, g_object_unref);

	G_OBJECT_CLASS(expidus_shell_parent_class)->finalize(obj);
}

static void expidus_shell_class_init(ExpidusShellClass* klass) {
	GObjectClass* obj_class = G_OBJECT_CLASS(klass);

	obj_class->constructed = expidus_shell_constructed;
	obj_class->finalize = expidus_shell_finalize;
	obj_class->set_property = expidus_shell_set_property;
	obj_class->get_property = expidus_shell_get_property;

	obj_props[PROP_PLUGIN] = g_param_spec_object("plugin", "Plugin", "The Mutter plugin to connect with.", META_TYPE_PLUGIN, G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY);
	obj_props[PROP_SETTINGS] = g_param_spec_object("settings", "Settings", "The instance of settings for the shell.", G_TYPE_SETTINGS, G_PARAM_READABLE);
	g_object_class_install_properties(obj_class, N_PROPS, obj_props);
}

static void expidus_shell_init(ExpidusShell* shell) {}

GList* expidus_shell_get_desktops(ExpidusShell* self) {
	g_return_val_if_fail(EXPIDUS_IS_SHELL(self), NULL);
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);
	g_return_val_if_fail(priv, NULL);
	return priv->desktops;
}

GSettings* expidus_shell_get_settings(ExpidusShell* self) {
	g_return_val_if_fail(EXPIDUS_IS_SHELL(self), NULL);
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);
	g_return_val_if_fail(priv, NULL);
	return priv->settings;
}

void expidus_shell_sync_desktops(ExpidusShell* self) {
	g_return_if_fail(EXPIDUS_IS_SHELL(self));
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);
	g_return_if_fail(priv);

	for (GList* item = priv->desktops; item != NULL; item = g_list_next(item)) {
		ExpidusShellBaseDesktop* desktop = item->data;
		if (desktop == NULL || !EXPIDUS_SHELL_IS_BASE_DESKTOP(desktop)) continue;
		gtk_widget_hide(GTK_WIDGET(desktop));
	}

	for (GList* item = priv->dashboards; item != NULL; item = g_list_next(item)) {
		ExpidusShellBaseDashboard* dashboard = item->data;
		if (dashboard == NULL || !EXPIDUS_SHELL_IS_BASE_DASHBOARD(dashboard)) continue;
		gtk_widget_hide(GTK_WIDGET(dashboard));
	}

	for (GList* item = priv->overlays; item != NULL; item = g_list_next(item)) {
		ExpidusShellOverlay* overlay = item->data;
		if (overlay == NULL || !EXPIDUS_SHELL_IS_OVERLAY(overlay)) continue;
		gtk_widget_hide(GTK_WIDGET(overlay));
	}

	g_clear_list(&priv->desktops, g_object_unref);
	g_clear_list(&priv->dashboards, g_object_unref);
	g_clear_list(&priv->overlays, g_object_unref);

  MetaDisplay* disp = meta_plugin_get_display(priv->plugin);
  for (int i = 0; i < meta_display_get_n_monitors(disp); i++) {
		ExpidusShellBaseDesktop* desktop = EXPIDUS_SHELL_BASE_DESKTOP(g_object_new(priv->desktop_type, "shell", self, "monitor-index", i, NULL));
		priv->desktops = g_list_append(priv->desktops, desktop);
		gtk_widget_show_all(GTK_WIDGET(desktop));

		ExpidusShellOverlay* overlay = EXPIDUS_SHELL_OVERLAY(g_object_new(EXPIDUS_SHELL_TYPE_OVERLAY, "shell", self, "monitor-index", i, NULL));
		priv->overlays = g_list_append(priv->overlays, overlay);
	}
}

void expidus_shell_toggle_dashboard(ExpidusShell* self, ExpidusShellDashboardStartMode start_mode) {
	g_return_if_fail(EXPIDUS_IS_SHELL(self));
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);
	g_return_if_fail(priv);

	gboolean is_opened = priv->dashboards != NULL;
	if (is_opened) expidus_shell_hide_dashboard(self);
	else expidus_shell_show_dashboard(self, start_mode);
}

void expidus_shell_show_dashboard(ExpidusShell* self, ExpidusShellDashboardStartMode start_mode) {
	g_return_if_fail(EXPIDUS_IS_SHELL(self));
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);
	g_return_if_fail(priv);

	gboolean is_opened = priv->dashboards != NULL;
	if (!is_opened) {
  	MetaDisplay* disp = meta_plugin_get_display(priv->plugin);
  	for (int i = 0; i < meta_display_get_n_monitors(disp); i++) {
			ExpidusShellBaseDashboard* dashboard = EXPIDUS_SHELL_BASE_DASHBOARD(g_object_new(priv->dashboard_type, "shell", self, "monitor-index", i, "start-mode", start_mode, NULL));
			priv->dashboards = g_list_append(priv->dashboards, dashboard);
			gtk_widget_show_all(GTK_WIDGET(dashboard));
  		gdk_window_set_events(gtk_widget_get_window(GTK_WIDGET(dashboard)), GDK_ALL_EVENTS_MASK);
		}
	}
}

void expidus_shell_hide_dashboard(ExpidusShell* self) {
	g_return_if_fail(EXPIDUS_IS_SHELL(self));
	ExpidusShellPrivate* priv = expidus_shell_get_instance_private(self);
	g_return_if_fail(priv);

	gboolean is_opened = priv->dashboards != NULL;
	if (is_opened) {
		for (GList* item = priv->dashboards; item != NULL; item = g_list_next(item)) {
			ExpidusShellBaseDashboard* dashboard = item->data;
			if (dashboard == NULL || !EXPIDUS_SHELL_IS_BASE_DASHBOARD(dashboard)) continue;
			gtk_widget_hide(GTK_WIDGET(dashboard));
		}
		g_clear_list(&priv->dashboards, g_object_unref);
	}
}