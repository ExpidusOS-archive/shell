# ExpidusOS Shell

The default desktop environment on ExpidusOS is called ExpidusOS Shell. This repository contains the code for building and running ExpidusOS Shell. It supports X11 and will support Wayland fully in the future.

## Requirements

### Dependencies
* `accountsservice` (runtime)
* `NetworkManager` (runtime)
* `mutter-7` (runtime, compiling)
* `meson` (host)
* (dart) [`dbus`](https://pub.dev/packages/dbus)^0.2.1 (host)
* Flutter SDK (host)

### Hardware
* Dedicated GPU: **recommended**
* CPU: Pentium 4 *or better*
* RAM: 1Gb *or higher*, 2Gb **recommended**

## Building & Installing

ExpidusOS Shell installs and builds just like any other meson project, however it requires the dbus package from dart to be installed along side the Flutter SDK. Without the dbus package, meson will not be able to generate the DBus object files which are necessary to make the Dart code run. Flutter's SDK is required as it builds the Dart code that uses Flutter for the shell. It is recommended to set the prefix to `/usr` when configuring the project with meson. Running the shell is easy, you can use any display manager like GDM or LightDM. It is also possible to use Xephyr to test the shell. Before running the shell, make sure Network Manager and the account service for DBus is running.