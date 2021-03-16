#include <expidus-shell/desktop.h>
#include <expidus-shell/flutter.h>

typedef struct {
  FlDartProject* proj;
  FlView* view;
} ExpidusShellDesktopPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDesktop, expidus_shell_desktop, GTK_TYPE_WINDOW);

static void expidus_shell_desktop_constructed(GObject* obj) {
  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->constructed(obj);

  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  GtkWindow* win = GTK_WINDOW(self);

  gtk_window_set_decorated(win, FALSE);
  gtk_window_set_type_hint(win, GDK_WINDOW_TYPE_HINT_DESKTOP);
  gtk_window_set_skip_taskbar_hint(win, TRUE);
  gtk_window_set_skip_pager_hint(win, TRUE);
  gtk_window_set_focus_on_map(win, FALSE);

  priv->proj = fl_dart_project_new();
  priv->view = fl_view_new(priv->proj);

  gtk_widget_show(GTK_WIDGET(priv->view));
  gtk_container_add(GTK_CONTAINER(win), GTK_WIDGET(priv->view));
  flutter_register_plugins(FL_PLUGIN_REGISTRY(priv->view));
}

static void expidus_shell_desktop_dispose(GObject* obj) {
  ExpidusShellDesktop* self = EXPIDUS_SHELL_DESKTOP(obj);
  ExpidusShellDesktopPrivate* priv = expidus_shell_desktop_get_instance_private(self);

  g_clear_object(&priv->view);
  g_clear_object(&priv->proj);

  G_OBJECT_CLASS(expidus_shell_desktop_parent_class)->dispose(obj);
}

static void expidus_shell_desktop_class_init(ExpidusShellDesktopClass* klass) {
  GObjectClass* obj_class = G_OBJECT_CLASS(klass);

  obj_class->constructed = expidus_shell_desktop_constructed;
  obj_class->dispose = expidus_shell_desktop_dispose;
}

static void expidus_shell_desktop_init(ExpidusShellDesktop* self) {}