# 🔧 Fixing the `/run/usbmuxd` Directory vs. Unix Socket Issue

## 📋 Overview

`usbmuxd` is the USB multiplexing daemon used by Linux to communicate with Apple devices, including iPhones and iPads. It is used by tools such as `libimobiledevice`, `pymobiledevice3`, and other iOS device utilities.

On Linux, the daemon typically exposes a Unix domain socket at:

```
/run/usbmuxd
```

A problem can occur when `/run/usbmuxd` exists as a **directory instead of a Unix socket**. Applications expecting to connect to the socket may fail, preventing communication with connected iOS devices.

This guide documents how to stop `usbmuxd`, remove stale runtime files, restart the service, and verify that `/run/usbmuxd` has been recreated as a socket.

## 🛠️ 1. Stop the usbmuxd Service

Stop the running service before removing any runtime files:

```
sudo systemctl stop usbmuxd.service
```

This prevents the daemon from using the runtime path while it is being repaired.

## 🧹 2. Remove Stale Runtime Files

Remove the PID file and the problematic runtime path:

```
sudo rm -f /run/usbmuxd.pid
sudo rm -rf /run/usbmuxd/
```

⚠️ **Warning:** The second command recursively deletes `/run/usbmuxd/`. Verify that the path is correct before executing it. Do not run this command against a different path or a directory containing unrelated data.

These commands remove stale runtime state so the service can recreate the expected socket.

## 🔄 3. Reset the Failed Service State

Clear any recorded systemd failure state:

```
sudo systemctl reset-failed usbmuxd.service
```

This resets systemd's failed-state tracking. It does not itself repair the socket.

## ▶️ 4. Restart usbmuxd

Start the service again:

```
sudo systemctl start usbmuxd.service
```

Check its status:

```
sudo systemctl status usbmuxd.service
```

A successful startup should report:

```
Active: active (running)
```

The log should also indicate that `usbmuxd` has started and completed initialization.

## 🔍 5. Verify That `/run/usbmuxd` Is a Unix Socket

Run:

```
ls -ld /run/usbmuxd
```

A successful result should begin with `s`, indicating a Unix domain socket:

```
srw-rw-rw- 1 root root 0 Oct 14 02:49 /run/usbmuxd
```

The important part is:

- `s` at the beginning of the permissions string — identifies a socket.
- `/run/usbmuxd` — the expected socket path.

By comparison, a directory would begin with `d`:

```
drwxr-xr-x ...
```

You can also use `file` to check the path:

```
file /run/usbmuxd
```

The output should identify it as a socket rather than a directory.

## 📱 6. Test iOS Device Connectivity

After confirming that the socket exists, connect your iPhone or iPad and test communication.

For example:

```
idevice_id -l
```

Or, if you use `pymobiledevice3`:

```
pymobiledevice3 usbmux list
```

The exact commands available depend on which tools and versions are installed. If the device still does not appear, check the USB connection, host permissions, and daemon logs.

To inspect recent logs:

```
sudo journalctl -u usbmuxd.service -n 50 --no-pager
```

## 🐳 7. Docker Integration

For a Docker-based iOS forensics environment, the host's `usbmuxd` socket can be mounted into the container:

```
docker run -it --rm \
  -v /run/usbmuxd:/run/usbmuxd \
  libimobiledevice-docker fish
```

This allows compatible tools inside the container to connect to the host's `usbmuxd` service without running another daemon inside the container.

**Important:** The socket must exist on the host before the container starts. If the host path is a directory instead of a socket, Docker may mount the directory into the container, causing applications to fail when they expect a Unix socket.

The host socket mount is particularly useful for a shared forensics environment that combines `libimobiledevice`, `pymobiledevice3`, and other iOS analysis tools.

## ✅ Quick Recovery Commands

If the same issue occurs again, the following sequence can be used after verifying that the runtime path is incorrect:

```
sudo systemctl stop usbmuxd.service
sudo rm -f /run/usbmuxd.pid
sudo rm -rf /run/usbmuxd/
sudo systemctl reset-failed usbmuxd.service
sudo systemctl start usbmuxd.service
sudo systemctl status usbmuxd.service
ls -ld /run/usbmuxd
```

Confirm that the final `ls -ld` output begins with `s`.

## 📝 Summary

The recovery process is:

1. 🛑 Stop `usbmuxd`.
2. 🧹 Remove stale runtime files.
3. 🔄 Reset the systemd failure state.
4. ▶️ Restart the daemon.
5. 🔍 Verify that `/run/usbmuxd` is a Unix socket.
6. 📱 Test communication with the connected iOS device.
7. 🐳 Mount the socket into Docker when host-based USB access is required.

This restores the expected runtime socket and can resolve connectivity problems caused by an incorrect `/run/usbmuxd` filesystem object.
