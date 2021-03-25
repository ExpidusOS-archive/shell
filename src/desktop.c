#include <expidus-shell/desktop.h>

typedef struct {
} ExpidusShellDesktopPrivate;
G_DEFINE_TYPE_WITH_PRIVATE(ExpidusShellDesktop, expidus_shell_desktop, GTK_TYPE_WINDOW);

static void expidus_shell_desktop_class_init(ExpidusShellDesktopClass* klass) {}
static void expidus_shell_desktop_init(ExpidusShellDesktop* self) {}