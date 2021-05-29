project('expidus-shell', 'vala', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

gnome = import('gnome')
fs = import('fs')

enable_x11 = get_option('enable_x11')
enable_wayland = get_option('enable_wayland')

gtk = [dependency('gtk+-3.0')]
gio = dependency('gio-2.0')
clutter = [dependency('clutter-1.0'), dependency('clutter-gtk-1.0')]
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

if enable_x11
	shell_sources += ['src/x11/compositor.vala', 'src/x11/window.vala']
	clutter += [dependency('clutter-x11-1.0')]
	extra_deps += [dependency('gdk-x11-3.0')]
	add_project_arguments('-D', 'ENABLE_X11', language: 'vala')
endif

executable('expidus-shell', [shell_res, shell_sources,
	'src/compositor.vala', 'src/main.vala', 'src/shell.vala', 'src/window.vala'],
	install: true,
	dependencies: [gtk, gio, clutter, extra_deps])

# Wallpaper & more
install_subdir('data/wallpaper',
	install_dir: join_paths(get_option('datadir'), 'backgrounds', 'expidus'),
	strip_directory: true)
install_subdir('data/schemas/settings',
	install_dir: gio.get_pkgconfig_variable('schemasdir'),
	strip_directory: true)
