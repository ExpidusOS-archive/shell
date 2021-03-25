project('expidus-shell', 'c', license: 'GPL-3.0-only', version: '0.1.0-prealpha')

flutter_exe = find_program('flutter', required: true)
dart_exe = find_program('dart', required: true)

gnome = import('gnome')
fs = import('fs')

gtk = dependency('gtk+-3.0')
gio = dependency('gio-2.0')
mutter = dependency('libmutter-7')

# Flutter variables
flutter_version = run_command('sh', ['-c', flutter_exe.full_path() + ' --version | head -n1 | cut -f2 -d \' \''])
if not (flutter_version.returncode() == 0)
	error('Failed to retrieve the flutter version')
endif
flutter_version = flutter_version.stdout().strip()

flutter_target = 'linux-'

if target_machine.cpu_family() == 'x86_64'
	flutter_target = flutter_target + 'x64'
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

# Flutter assets
custom_target('assets',
	build_by_default: true,
	output: 'flutter_assets',
	input: 'lib/main.dart',
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
conf_data.set('LIBDIR', get_option('libdir'))
conf_data.set('LIBEXECDIR', get_option('libexecdir'))
conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('EXPIDUS_SHELL_VERSION', meson.project_version())
configure_file(input: 'data/build.h.in', output: 'expidus-build.h', configuration: conf_data)

shell_res = gnome.compile_resources('expidus-shell-resources', 'data/res/shell.gresource.xml',
	source_dir: 'data/res',
	c_name: 'expidus_shell')

executable('expidus-shell.bin', [shell_res, 'src/desktop.c', 'src/main.c', 'src/plugin.c', 'src/shell.c'],
	include_directories: include_directories('include'),
	install: true,
	build_rpath: mutter_rpath,
	install_rpath: mutter_rpath,
	install_dir: join_paths(get_option('prefix'), get_option('libexecdir'), 'expidus-shell-' + meson.project_version()),
	link_args: ['-L' + join_paths(flutter_enginedir, flutter_full_target), '-lflutter_linux_gtk'],
	dependencies: [gtk, gio, mutter])

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