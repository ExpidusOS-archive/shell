#include <expidus-shell/flutter.h>
#include "../flutter/generated_plugin_registrant.h"

extern "C" void flutter_register_plugins(FlPluginRegistry* registry) {
  fl_register_plugins(registry);
}