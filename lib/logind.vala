namespace Logind {
	[DBus(name = "org.freedesktop.login1.Manager")]
	private interface Manager : GLib.Object {
		public abstract string can_halt() throws GLib.Error;
		public abstract string can_hibernate() throws GLib.Error;
		public abstract string can_hybrid_sleep() throws GLib.Error;
		public abstract string can_power_off() throws GLib.Error;
		public abstract string can_reboot() throws GLib.Error;

		public abstract void halt(bool interactive) throws GLib.Error;
		public abstract void hibernate(bool interactive) throws GLib.Error;
		public abstract void power_off(bool interactive) throws GLib.Error;
		public abstract void reboot(bool interactive) throws GLib.Error;
		public abstract void suspend(bool interactive) throws GLib.Error;
		public abstract void suspend_then_hibernate(bool interactive) throws GLib.Error;
	}

	public class Client {
		private Manager _manager;
		private bool _can_halt;
		private bool _can_hibernate;
		private bool _can_hybrid_sleep;
		private bool _can_poweroff;
		private bool _can_reboot;

		public bool can_halt {
			get {
				try {
					return this.parse_bool(this._manager.can_halt());
				} catch (GLib.Error e) {
					return this._can_halt;
				}
			}
		}

		public bool can_hibernate {
			get {
				try {
					return this.parse_bool(this._manager.can_hibernate());
				} catch (GLib.Error e) {
					return this._can_hibernate;
				}
			}
		}

		public bool can_hybrid_sleep {
			get {
				try {
					return this.parse_bool(this._manager.can_hybrid_sleep());
				} catch (GLib.Error e) {
					return this._can_hybrid_sleep;
				}
			}
		}

		public bool can_poweroff {
			get {
				try {
					return this.parse_bool(this._manager.can_power_off());
				} catch (GLib.Error e) {
					return this._can_poweroff;
				}
			}
		}

		public bool can_reboot {
			get {
				try {
					return this.parse_bool(this._manager.can_reboot());
				} catch (GLib.Error e) {
					return this._can_reboot;
				}
			}
		}

		public Client() throws GLib.IOError, GLib.Error {
			this._manager = GLib.Bus.get_proxy_sync<Manager>(BusType.SYSTEM, "org.freedesktop.login1", "/org/freedesktop/login1");
			assert(this._manager != null);

			this._can_halt = this.parse_bool(this._manager.can_halt());
			this._can_hibernate = this.parse_bool(this._manager.can_hibernate());
			this._can_hybrid_sleep = this.parse_bool(this._manager.can_hybrid_sleep());
			this._can_poweroff = this.parse_bool(this._manager.can_power_off());
			this._can_reboot = this.parse_bool(this._manager.can_reboot());
		}

		public void halt(bool interactive = false) throws GLib.Error {
			this._manager.halt(interactive);
		}

		public void hibernate(bool interactive = false) throws GLib.Error {
			this._manager.hibernate(interactive);
		}

		public void poweroff(bool interactive = false) throws GLib.Error {
			this._manager.power_off(interactive);
		}

		public void reboot(bool interactive = false) throws GLib.Error {
			this._manager.reboot(interactive);
		}

		public void suspend(bool interactive = false) throws GLib.Error {
			this._manager.suspend(interactive);
		}

		public void suspend_then_hibernate(bool interactive = false) throws GLib.Error {
			this._manager.suspend_then_hibernate(interactive);
		}

		private bool parse_bool(string str) {
			return str == "yes";
		}
	}
}
