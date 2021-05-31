project('expidus-shell', 'vala', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

gnome = import('gnome')
fs = import('fs')

gtk = [dependency('gtk+-3.0')]
gio = dependency('gio-2.0')
clutter = [dependency('clutter-1.0'), dependency('clutter-gtk-1.0')]
json = [dependency('json-glib-1.0')]
xfce = [dependency('libxfconf-0')]
extra_deps = []

# Shell executable
conf_data = configuration_data()
conf_data.set('PREFIX', get_option('prefix'))
conf_data.set('BINDIR', get_option('bindir'))
conf_data.set('LIBDIR', get_option('libdir'))
conf_data.set('LIBEXECDIR', get_option('libexecdir'))
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('EXPIDUS_SHELL_VERSION', meson.project_version())
configure_file(input: 'data/expidus-shell.desktop.in', output: 'expidus-shell.desktop', configuration: conf_data, install: true, install_dir: join_paths(get_option('datadir'), 'xsessions'))

shell_res = gnome.compile_resources('expidus-shell-resources', 'data/res/shell.gresource.xml',
	source_dir: 'data/res',
	c_name: 'expidus_shell')

shell_sources = []

add_project_arguments('-DXFCONF_G__ERROR=xfconf_get_error_quark()', language: 'c')
executable('expidus-shell', [shell_res, shell_sources, 'src/desktop.vala', 'src/main.vala', 'src/monitor.vala', 'src/shell.vala', 'src/xfconf.vala'],
	install: true,
	dependencies: [gtk, gio, clutter, json, xfce, extra_deps])

# Wallpaper & more
install_subdir('data/wallpaper',
	install_dir: join_paths(get_option('datadir'), 'backgrounds', 'expidus'),
	strip_directory: true)
install_subdir('data/schemas/settings',
	install_dir: gio.get_pkgconfig_variable('schemasdir'),
	strip_directory: true)
