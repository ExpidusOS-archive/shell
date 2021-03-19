#pragma once

#include <flutter_linux/flutter_linux.h>
#include <expidus-shell/plugin.h>

void expidus_shell_messanger_init_applications(ExpidusShellPlugin* plugin, FlEngine* engine);
void expidus_shell_messanger_init_settings(ExpidusShellPlugin* plugin, FlEngine* engine);
void expidus_shell_messanger_init(ExpidusShellPlugin* plugin, FlEngine* engine);