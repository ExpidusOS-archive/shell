namespace ExpidusOSShell {
	public class BatteryIndicator : Gtk.Bin {
		private Shell shell;
		private Gtk.Image icon;
		private Up.Device dev;
		private GLib.TimeoutSource timeout;

		public BatteryIndicator(Shell shell) {
			this.shell = shell;
			this.icon = new Gtk.Image();
			this.icon.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
			this.icon.icon_name = "battery-missing";
			this.icon.set_no_show_all(false);
			this.add(this.icon);

			var devices = this.shell.upower.get_devices2();
			for (var i = 0; i < devices.length; i++) {
				var dev = devices.get(i);
        if (dev.kind == Up.DeviceKind.BATTERY) {
					this.dev = dev;
					this.icon.show();
					break;
				}
			}

			this.shell.upower.device_added.connect((dev) => {
				if (this.dev == null && dev.kind == Up.DeviceKind.BATTERY) {
					this.dev = dev;
					this.icon.show();
				}
			});

			this.shell.upower.device_removed.connect((obj_path) => {
				if (this.dev != null) {
					if (!this.dev.is_present) {
						this.dev = null;
						this.icon.hide();
					}
				}
			});

			this.timeout = new GLib.TimeoutSource.seconds(15);
			this.timeout.set_callback(() => {
				if (this.dev != null) {
					var per = (this.dev.energy - this.dev.energy_empty) / this.dev.energy_full;
					var level = "";

					if (per < 0.1) level = "caution";
					else if (per < 0.3) level = "low";
					else if (per < 0.95) level = "good";
					else level = "full";

					var suffix = "";
					switch (dev.state) {
						case Up.DeviceState.CHARGING:
							suffix = "-charging";
							break;
						case Up.DeviceState.FULLY_CHARGED:
							level = "full";
							break;
						case Up.DeviceState.EMPTY:
							level = "empty";
							break;
					}

					this.icon.icon_name = "battery-" + level + suffix;
				}
				return true;
			});
			this.timeout.attach(this.shell.main_loop.get_context());
		}

		~BatteryIndicator() {
			this.timeout.destroy();
		}
	}
	public class NetworkIndicator : Gtk.Box {
		private Shell shell;

		private Gtk.Image wifi_icon;
		private Gtk.Button wifi_btn;

		private Gtk.Image eth_icon;
		private Gtk.Button eth_btn;

		private Gtk.Image cell_icon;
		private Gtk.Button cell_btn;

		private GLib.TimeoutSource timeout;

		public NetworkIndicator(Shell shell) {
			this.shell = shell;

			this.wifi_icon = new Gtk.Image();
			this.wifi_btn = new Gtk.Button();
			this.wifi_btn.set_always_show_image(true);
			this.wifi_btn.set_image(this.wifi_icon);
			this.wifi_btn.relief = Gtk.ReliefStyle.NONE;

			var style_ctx = this.wifi_btn.get_style_context();
			style_ctx.add_class("expidus-shell-panel-button");
			this.wifi_icon.icon_name = "network-wireless-acquiring";
			this.wifi_icon.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
			this.add(this.wifi_btn);

			this.eth_icon = new Gtk.Image();
			this.eth_btn = new Gtk.Button();
			this.eth_btn.set_always_show_image(true);
			this.eth_btn.set_image(this.eth_icon);
			this.eth_btn.relief = Gtk.ReliefStyle.NONE;

			style_ctx = this.eth_btn.get_style_context();
			style_ctx.add_class("expidus-shell-panel-button");
			this.eth_icon.icon_name = "network-wired";
			this.eth_icon.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
			this.add(this.eth_btn);

			this.cell_icon = new Gtk.Image();
			this.cell_btn = new Gtk.Button();
			this.cell_btn.set_always_show_image(true);
			this.cell_btn.set_image(this.cell_icon);
			this.cell_btn.relief = Gtk.ReliefStyle.NONE;

			style_ctx = this.cell_btn.get_style_context();
			style_ctx.add_class("expidus-shell-panel-button");
			this.cell_icon.icon_size = Gtk.IconSize.SMALL_TOOLBAR;
			this.cell_icon.icon_name = "network-cellular-acquiring";
			this.add(this.cell_btn);

			this.timeout = new GLib.TimeoutSource.seconds(5);
			this.timeout.set_callback(() => {
				return true;
			});
			this.timeout.attach(this.shell.main_loop.get_context());
		}

		~NetworkIndicator() {
			this.timeout.destroy();
		}

		private NM.Device? find_device(NM.DeviceType type) {
			for (var i = 0; i < this.shell.nm.all_devices.length; i++) {
				var device = this.shell.nm.all_devices.get(i);
				if (device.device_type == type) return device;
			}
			return null;
		}

		public void update() {
			var wifi = this.find_device(NM.DeviceType.WIFI) as NM.DeviceWifi;
			var eth = this.find_device(NM.DeviceType.ETHERNET) as NM.DeviceEthernet;
			var cell = this.find_device(NM.DeviceType.MODEM) as NM.DeviceModem;

			if (wifi != null && this.shell.nm.wireless_hardware_enabled) {
				if (wifi.active_access_point == null) {
					this.wifi_icon.icon_name = "network-wireless-offline";
				}
				this.wifi_btn.show();

				this.timeout.set_callback(() => {
					if (wifi.active_access_point == null) {
						this.wifi_icon.icon_name = "network-wireless-offline";
					} else {
						var strength = wifi.active_access_point.get_strength();

						if (strength == 0) this.wifi_icon.icon_name = "network-wireless-signal-none";
						else if (strength < 30) this.wifi_icon.icon_name = "network-wireless-signal-weak";
						else if (strength < 70) this.wifi_icon.icon_name = "network-wireless-signal-ok";
						else if (strength < 90) this.wifi_icon.icon_name = "network-wireless-signal-good";
						else this.wifi_icon.icon_name = "network-wireless-signal-excellent";
					}
					return true;
				});

				wifi.state_changed.connect((n, o, r) => {
					if (n != o) {
						switch (n) {
							case NM.DeviceState.PREPARE:
								this.eth_icon.icon_name = "network-wireless-acquiring";
								break;
							case NM.DeviceState.FAILED:
								this.eth_icon.icon_name = "network-wireless-offline";
								break;
							case NM.DeviceState.UNAVAILABLE:
								this.eth_icon.icon_name = "network-wireless-no-route";
								break;
						}
					}
				});
			} else {
				this.wifi_btn.hide();
			}

			if (eth != null) {
				if (eth.carrier) {
					this.eth_icon.icon_name = "network-wired";
					this.eth_btn.show();
				} else {
					this.eth_icon.icon_name = "network-wired-no-route";
					this.eth_btn.hide();
				}

				eth.state_changed.connect((n, o, r) => {
					if (n != o) {
						switch (n) {
							case NM.DeviceState.ACTIVATED:
								this.eth_icon.icon_name = "network-wired";
								break;
							case NM.DeviceState.PREPARE:
								this.eth_icon.icon_name = "network-wired-acquiring";
								break;
							case NM.DeviceState.FAILED:
								this.eth_icon.icon_name = "network-wired-offline";
								break;
							case NM.DeviceState.UNAVAILABLE:
								this.eth_icon.icon_name = "network-wired-no-route";
								break;
						}
					}
				});
			} else {
				this.eth_btn.hide();
			}

			if (cell != null) {
				if (cell.active_connection == null) this.cell_icon.icon_name = "network-cellular-offline";
				else this.cell_icon.icon_name = "network-cellular-connected";

				this.cell_btn.show();
			} else {
				this.cell_btn.hide();
			}
		}
	}
	public class SoundIndicator : Gtk.Box {
		private Shell shell;

		private Gtk.Image sink_icon;
		private Gtk.Button sink_btn;

		public SoundIndicator(Shell shell) {
			this.shell = shell;

			this.sink_icon = new Gtk.Image();
			this.sink_icon.icon_size = Gtk.IconSize.SMALL_TOOLBAR;

			this.sink_btn = new Gtk.Button();
			this.sink_btn.set_always_show_image(true);
			this.sink_btn.set_image(this.sink_icon);
			this.sink_btn.relief = Gtk.ReliefStyle.NONE;

			var style_ctx = this.sink_btn.get_style_context();
			style_ctx.add_class("expidus-shell-panel-button");

			this.add(this.sink_btn);
		}

		public void update() {
			this.shell.pulse.get_server_info((c, server_info) => {
				c.get_sink_info_by_name(server_info.default_sink_name, (c, sink_info, eol) => {
					if (sink_info != null) {
						var vol = sink_info.volume.avg();
						if (vol > PulseAudio.Volume.NORM) vol = PulseAudio.Volume.NORM;

						double v = vol * 1.0 / PulseAudio.Volume.NORM;
						this.sink_icon.icon_name = Utils.audio_icon_name(false, sink_info.mute == 1, v);
					}
				});
			});
		}
	}
}
