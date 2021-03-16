#include <expidus-shell/plugin.h>
#include <meta/main.h>
#include <glib.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  GOptionContext* ctx = meta_get_option_context();
  g_assert(ctx);

  GError* error = NULL;
  if (!g_option_context_parse(ctx, &argc, &argv, &error)) {
    g_error("Failed to parse arguments: %s", error->message);
    g_clear_error(&error);
    g_option_context_free(ctx);
    return EXIT_FAILURE;
  }

  g_option_context_free(ctx);

  meta_set_wm_name("ExpidusOS Shell");
  meta_plugin_manager_set_plugin_type(EXPIDUS_SHELL_TYPE_PLUGIN);
  meta_init();
  return meta_run();
}