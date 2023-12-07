import os

import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib


def get_pids():
    # Define the path to the directory
    path = '/proc'

    # Get a list of all directories in the path
    directories = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]

    # Filter out directories that contain only numbers in their names
    return [d for d in directories if d.isnumeric()]


class HelloWorld(dbus.service.Object):
    def __init__(self, conn=None, object_path=None, bus_name=None):
        dbus.service.Object.__init__(self, conn, object_path, bus_name)

    @dbus.service.method(dbus_interface="com.github.stsdc.monitor.workaround.GetProcesses", in_signature="s", out_signature="as", sender_keyword="sender", connection_keyword="conn")
    def get_processes(self, name, sender=None, conn=None):
        return get_pids()

if __name__ == "__main__":
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    name = dbus.service.BusName("com.github.stsdc.monitor.workaround", bus)
    helloworld = HelloWorld(bus, "/processes")
    mainloop = GLib.MainLoop()
    mainloop.run()

