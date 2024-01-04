#!/usr/bin/python

"""The workaround script should run only in Flatpak environment."""

import os
import subprocess
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

def get_processes_stats():
    processes = []
    for pid in get_pids():
        process = [pid]
        with open(f'/proc/{pid}/stat', 'r') as file:
            process.append(file.read())
        processes.append(process)
    return processes


class HelloWorld(dbus.service.Object):

    def __init__(self, conn=None, object_path=None, bus_name=None):
        dbus.service.Object.__init__(self, conn, object_path, bus_name)

    @dbus.service.method(dbus_interface="com.github.stsdc.monitor.workaround.GetProcesses", in_signature="s", out_signature="aa{ss}", sender_keyword="sender", connection_keyword="conn")
    def GetProcesses(self, name, sender=None, conn=None):
        print("WorkaroundServer: GetProcesses")
        processes = []
        for pid in get_pids():
            process = {
                "pid": pid,
                "cmdline": "",
                "stat": "",
                "statm": "",
                "status": "",
                "io": "",
                "children": ""
            }
            try:
                with open(f'/proc/{pid}/cmdline', 'rb') as file:
                    process["cmdline"] = (file.read().decode('utf-8', 'ignore').replace('\0', ' '))
            except FileNotFoundError as err:
                process["cmdline"] = None
                continue
        
            with open(f'/proc/{pid}/stat', 'rb') as file:
                process["stat"] = (file.read().decode('utf-8', 'ignore').replace('\0', ' '))

            with open(f'/proc/{pid}/status', 'rb') as file:
                process["status"] = (file.read().decode('utf-8', 'ignore').replace('\0', ' '))

            with open(f'/proc/{pid}/task/{pid}/children', 'rb') as file:
                process["children"] = (file.read().decode('utf-8', 'ignore').replace('\0', ' '))
            
            with open(f'/proc/{pid}/statm', 'rb') as file:
                process["statm"] = (file.read().decode('utf-8', 'ignore').replace('\0', ' '))
                try:
                    with open(f'/proc/{pid}/io', 'rb') as file:
                        process["io"] = (file.read().decode('utf-8', 'ignore').replace('\0', ' '))
                        # print(process["io"])

                except PermissionError as err:
                    # print(err)
                    pass
            processes.append(process)
        return processes

    @dbus.service.method(dbus_interface="com.github.stsdc.monitor.workaround.GetProcesses", in_signature="i", sender_keyword="sender", connection_keyword="conn")
    def EndProcess(self, pid, sender=None, conn=None):
        print(f"WorkaroundServer: EndProcess: kill -15 {pid}")
        try:
            (subprocess.check_output(["kill", "-15", str(pid)], stderr=subprocess.STDOUT, shell=False)).decode()
        except subprocess.CalledProcessError as err:
            print(err)

    @dbus.service.method(dbus_interface="com.github.stsdc.monitor.workaround.GetProcesses", in_signature="i", sender_keyword="sender", connection_keyword="conn")
    def KillProcess(self, pid, sender=None, conn=None):
        print(f"WorkaroundServer: KillProcess: kill -9 {pid}")
        try:
            (subprocess.check_output(["kill", "-9", str(pid)], stderr=subprocess.STDOUT, shell=False)).decode()
        except subprocess.CalledProcessError as err:
            print(err)

if __name__ == "__main__":
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    name = dbus.service.BusName("com.github.stsdc.monitor.workaround", bus)
    helloworld = HelloWorld(bus, "/com/github/stsdc/monitor/workaround")
    mainloop = GLib.MainLoop()
    mainloop.run()
