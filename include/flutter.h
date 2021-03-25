#pragma once

#include <flutter_linux/flutter_linux.h>

struct _FlDartProject {
  GObject parent_instance;

  gboolean enable_mirrors;
  gchar* aot_library_path;
  gchar* assets_path;
  gchar* icu_data_path;
  gchar** dart_entrypoint_args;
};