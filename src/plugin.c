#include <expidus-shell/plugin.h>
#include <expidus-shell/shell.h>
#include <meta/meta-background.h>
#include <meta/meta-background-actor.h>
#include <meta/meta-background-content.h>
#include <meta/meta-background-group.h>
#include <meta/meta-monitor-manager.h>
#include <meta/meta-workspace-manager.h>

typedef struct {
  ClutterActor* bg_group;
  ExpidusShell* shell;
} ExpidusShellPluginPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellPlugin, expidus_shell_plugin, META_TYPE_PLUGIN);

static void on_monitors_changed(MetaMonitorManager* mmngr, MetaPlugin* plugin) {
  ExpidusShellPlugin* self = EXPIDUS_SHELL_PLUGIN(plugin);
  ExpidusShellPluginPrivate* priv = expidus_shell_plugin_get_instance_private(self);

  MetaDisplay* disp = meta_plugin_get_display(plugin);
  clutter_actor_destroy_all_children(priv->bg_group);

  for (int i = 0; i < meta_display_get_n_monitors(disp); i++) {
    MetaRectangle rect;
    meta_display_get_monitor_geometry(disp, i, &rect);

    ClutterActor* bg_actor = meta_background_actor_new(disp, i);
    ClutterContent* content = clutter_actor_get_content(bg_actor);
    MetaBackgroundContent* bg_content = META_BACKGROUND_CONTENT(content);

    clutter_actor_set_position(bg_actor, rect.x, rect.y);
    clutter_actor_set_size(bg_actor, rect.width, rect.height);

    MetaBackground* bg = meta_background_new(disp);
    
    ClutterColor color;
    clutter_color_init(&color, 0x1a, 0x1b, 0x26, 0xff);
    meta_background_set_color(bg, &color);
    meta_background_content_set_background(bg_content, bg);
    g_object_unref(bg);

    clutter_actor_add_child(priv->bg_group, bg_actor);
  }

  expidus_shell_sync_desktops(priv->shell);
}

static void expidus_shell_plugin_start(MetaPlugin* plugin) {
  ExpidusShellPlugin* self = EXPIDUS_SHELL_PLUGIN(plugin);
  ExpidusShellPluginPrivate* priv = expidus_shell_plugin_get_instance_private(self);

  MetaDisplay* disp = meta_plugin_get_display(plugin);
  MetaMonitorManager* mmngr = meta_monitor_manager_get();

  priv->bg_group = meta_background_group_new();
  clutter_actor_insert_child_below(meta_get_window_group_for_display(disp), priv->bg_group, NULL);

  g_signal_connect(mmngr, "monitors-changed", G_CALLBACK(on_monitors_changed), plugin);
  on_monitors_changed(mmngr, plugin);

  clutter_actor_show(meta_get_stage_for_display(disp));

  GtkCssProvider* css_provider = gtk_css_provider_new();
  gtk_css_provider_load_from_resource(css_provider, "/com/expidus/shell/style.css");
  gtk_style_context_add_provider_for_screen(gdk_screen_get_default(), GTK_STYLE_PROVIDER(css_provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
}

static void expidus_shell_plugin_map(MetaPlugin* plugin, MetaWindowActor* win_actor) {
  MetaWindow* win = meta_window_actor_get_meta_window(win_actor);
  MetaWindowType type = meta_window_get_window_type(win);

  if (type == META_WINDOW_NORMAL) {
  } else meta_plugin_map_completed(plugin, win_actor);
}

static void expidus_shell_plugin_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_plugin_parent_class)->constructed(obj);

  ExpidusShellPlugin* self = EXPIDUS_SHELL_PLUGIN(obj);
  ExpidusShellPluginPrivate* priv = expidus_shell_plugin_get_instance_private(self);

  priv->shell = g_object_new(EXPIDUS_TYPE_SHELL, "plugin", self, NULL);
}

static void expidus_shell_plugin_dispose(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_plugin_parent_class)->dispose(obj);
}

static void expidus_shell_plugin_finalize(GObject* obj) {
  ExpidusShellPlugin* self = EXPIDUS_SHELL_PLUGIN(obj);
  ExpidusShellPluginPrivate* priv = expidus_shell_plugin_get_instance_private(self);

  g_clear_object(&priv->shell);

  G_OBJECT_CLASS(expidus_shell_plugin_parent_class)->finalize(obj);
}

static void expidus_shell_plugin_class_init(ExpidusShellPluginClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);
  MetaPluginClass* plugin_class = META_PLUGIN_CLASS(klass);

  obj_class->constructed = expidus_shell_plugin_constructed;
  obj_class->dispose = expidus_shell_plugin_dispose;
  obj_class->finalize = expidus_shell_plugin_finalize;

  plugin_class->start = expidus_shell_plugin_start;
  plugin_class->map = expidus_shell_plugin_map;
}

static void expidus_shell_plugin_init(ExpidusShellPlugin* self) {}