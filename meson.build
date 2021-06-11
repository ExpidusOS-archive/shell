project('expidus-shell', 'vala', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

gnome = import('gnome')
fs = import('fs')

gtk = [dependency('gtk+-3.0'), dependency('gdk-x11-3.0')]
gio = dependency('gio-2.0')
deps = [
	gtk, gio, dependency('libxfconf-0'),
	dependency('libnm'),
	meson.get_compiler('c').find_library('m', required: true)
]

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

add_project_arguments('-DXFCONF_G__ERROR=xfconf_get_error_quark()', '-DWNCK_WINDOW_H=1', language: 'c')
executable('expidus-shell', [shell_res, shell_sources,
	'src/list-models/notifications.vala',
	'src/widgets/base-panel.vala', 'src/widgets/desktop.vala', 'src/widgets/indicators.vala', 'src/widgets/notifications.vala', 'src/widgets/panel.vala', 'src/widgets/side-panel.vala', 'src/widgets/startup-window.vala', 'src/widgets/status-area.vala',
	'src/main.vala', 'src/monitor.vala', 'src/notifications.vala', 'src/shell.vala', 'src/utils.vala', 'src/xfconf.vala'],
	install: true,
	dependencies: [deps])

# Wallpaper & more
install_subdir('data/wallpaper',
	install_dir: join_paths(get_option('datadir'), 'backgrounds', 'expidus'),
	strip_directory: true)
install_subdir('data/schemas/settings',
	install_dir: gio.get_pkgconfig_variable('schemasdir'),
	strip_directory: true)
