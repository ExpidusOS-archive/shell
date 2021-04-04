project('expidus-shell', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

flutter_exe = find_program('flutter', required: true)
dart_exe = find_program('dart', required: true)
dart_dbus_exe = find_program('dart-dbus', required: true)

gnome = import('gnome')
fs = import('fs')

gtk = dependency('gtk+-3.0')
gio = dependency('gio-2.0')
mutter = dependency('libmutter-7')
wnck = dependency('libwnck-3.0')
dbus = dependency('dbus-1')

# Flutter variables
flutter_version = run_command('sh', ['-c', flutter_exe.full_path() + ' --version | head -n1 | cut -f2 -d \' \''])
if not (flutter_version.returncode() == 0)
	error('Failed to retrieve the flutter version')
endif
flutter_version = flutter_version.stdout().strip()

flutter_target = 'linux-'

if target_machine.cpu_family() == 'x86_64'
	flutter_target = flutter_target + 'x64'
elif target_machine.cpu_family() == 'aarch64'
	flutter_target = flutter_target + 'arm64'
else
	error('Unsupported CPU family: ' + target_machine.cpu_family())
endif
flutter_full_target = flutter_target

flutter_bundle_args = []
if get_option('buildtype') == 'release'
	flutter_full_target = flutter_full_target + '-release'
else
	flutter_bundle_args += '--debug'
endif

# Special paths
flutter_enginedir = join_paths(fs.parent(flutter_exe.full_path()), 'cache', 'artifacts', 'engine')
mutter_rpath = join_paths(mutter.get_pkgconfig_variable('libdir'), 'mutter-' + mutter.get_pkgconfig_variable('apiversion'))
shell_libdir = join_paths(get_option('libdir'), 'expidus-shell-' + meson.project_version())
dbus_iface_paths = ['data/dbus', dbus.get_pkgconfig_variable('interfaces_dir')]
dbus_ifaces = ['org.freedesktop.Accounts.User', 'org.freedesktop.Accounts']

dbus_ifaces_real_paths = []
foreach iface : dbus_ifaces
	added_path = false
	foreach path : dbus_iface_paths
		p = join_paths(path, iface + '.xml')
		if fs.is_file(p) or fs.is_symlink(p)
			dbus_ifaces_real_paths += [p]
			added_path = true
			break
		endif
	endforeach
	if not added_path
		error('Cannot find the interface for ' + iface)
	endif
endforeach

foreach p : dbus_ifaces_real_paths
	iface = fs.replace_suffix(fs.name(p), '')
	message('Generating Dart DBus client and remote objects for ' + iface + ' (' + p + ')')
	client = run_command(dart_dbus_exe, ['generate-object', p, '-o', join_paths(meson.current_source_dir(), 'lib/dbus/' + iface + '.dart')])
	remote = run_command(dart_dbus_exe, ['generate-remote-object', p, '-o', join_paths(meson.current_source_dir(), 'lib/dbus/' + iface + '-remote.dart')])

	if not (client.returncode() == 0)
		error('Failed to compile the client DBus Dart object: ' + client.stderr())
	endif
	if not (remote.returncode() == 0)
		error('Failed to compile the remote DBus Dart object: ' + remote.stderr())
	endif
endforeach

# Flutter assets
custom_target('assets',
	build_by_default: true,
	output: 'flutter_assets',
	input: 'lib/main.dart',
	depend_files: ['lib/ui/dashboard.dart', 'lib/ui/desktop.dart', 'lib/main.dart'],
	command: [flutter_exe, 'build', 'bundle',
		'--asset-dir', join_paths(meson.current_build_dir(), 'flutter_assets'),
		'--target-platform', flutter_target,
		'--depfile', join_paths(meson.current_build_dir(), 'snapshot_blob.bin.d'),
		flutter_bundle_args])
install_subdir(join_paths(meson.current_build_dir(), 'flutter_assets'),
	install_dir: join_paths(shell_libdir, 'assets'),
	strip_directory: true)
install_data(join_paths(flutter_enginedir, flutter_target, 'icudtl.dat'),
	install_dir: shell_libdir)
install_data(join_paths(flutter_enginedir, flutter_full_target, 'libflutter_linux_gtk.so'),
	install_dir: shell_libdir)

# Flutter snapshot
if get_option('buildtype') == 'release'
	custom_target('app-dill',
		build_by_default: true,
		output: 'app.dill',
		input: 'lib/main.dart',
		command: [dart_exe, join_paths(flutter_enginedir, flutter_target, 'frontend_server.dart.snapshot'),
			'--sdk-root', join_paths(flutter_enginedir, 'common', 'flutter_patched_sdk_product'),
			'--target=flutter', '--aot', '--tfa', '-Ddart.vm.product=true',
			'--packages', join_paths(meson.current_source_dir(), '.packages'),
			'--output-dill', join_paths(meson.current_build_dir(), 'app.dill'), 'package:shell/main.dart'])
	custom_target('gen-snapshot',
		build_by_default: true,
		output: 'libapp.so',
		input: join_paths(meson.current_build_dir(), 'app.dill'),
		command: [join_paths(flutter_enginedir, flutter_target + '-release', 'gen_snapshot'),
			'--lazy_async_stacks', '--deterministic', '--snapshot_kind=app-aot-elf',
			'--elf=' + join_paths(meson.current_build_dir(), 'libapp.so'),
			'--strip', join_paths(meson.current_build_dir(), 'app.dill')],
		install: true,
		install_dir: shell_libdir)
endif

# Shell executable
conf_data = configuration_data()
conf_data.set('FLUTTER_VERSION', flutter_version)
conf_data.set('FLUTTER_TARGET', flutter_target)
conf_data.set('FLUTTER_FULL_TARGET', flutter_full_target)
conf_data.set('PREFIX', get_option('prefix'))
conf_data.set('BINDIR', get_option('bindir'))
conf_data.set('LIBDIR', get_option('libdir'))
conf_data.set('LIBEXECDIR', get_option('libexecdir'))
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('EXPIDUS_SHELL_VERSION', meson.project_version())
configure_file(input: 'data/build.h.in', output: 'expidus-build.h', configuration: conf_data)
configure_file(input: 'data/expidus-shell.desktop.in', output: 'expidus-shell.desktop', configuration: conf_data, install: true, install_dir: join_paths(get_option('datadir'), 'xsessions'))

shell_res = gnome.compile_resources('expidus-shell-resources', 'data/res/shell.gresource.xml',
	source_dir: 'data/res',
	c_name: 'expidus_shell')
shell_enums = gnome.mkenums_simple('expidus-shell-enums', sources: ['include/expidus-shell/base-dashboard.h'])

executable('expidus-shell.bin', [shell_res, shell_enums,
		'src/ui/dashboard.c', 'src/ui/desktop.c',
		'src/base-dashboard.c', 'src/base-desktop.c',
		'src/main.c', 'src/overlay.c', 'src/plugin.c', 'src/shell.c', 'src/utils.c'],
	include_directories: include_directories('include', 'include/expidus-shell', join_paths(flutter_enginedir, flutter_full_target)),
	install: true,
	build_rpath: mutter_rpath,
	install_rpath: mutter_rpath,
	install_dir: join_paths(get_option('prefix'), get_option('libexecdir'), 'expidus-shell-' + meson.project_version()),
	dependencies: [gtk, gio, mutter, wnck,
		meson.get_compiler('c').find_library('flutter_linux_gtk', dirs: join_paths(flutter_enginedir, flutter_full_target))])

configure_file(input: 'data/expidus-shell.sh.in', output: 'expidus-shell',
	install: true,
	install_dir: join_paths(get_option('prefix'), get_option('bindir')),
	install_mode: 'rwxrwxrwx',
	configuration: conf_data)

# Wallpaper & more
install_subdir('data/wallpaper',
	install_dir: join_paths(get_option('datadir'), 'backgrounds', 'expidus'),
	strip_directory: true)
install_subdir('data/schemas/settings',
	install_dir: gio.get_pkgconfig_variable('schemasdir'),
	strip_directory: true)