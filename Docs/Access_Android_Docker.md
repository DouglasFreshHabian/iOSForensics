## 🤖 Android Device Access from Docker

This Docker environment supports both iOS and Android device forensics. iOS communication is handled through `libimobiledevice`, `pymobiledevice3`, and `usbmuxd`, while Android tools include **ADB**, **AndroidQF**, and **MVT**.

### 🔌 Why Use the Host's ADB Server?

Direct USB passthrough into Docker can be unreliable, even when the Android device is visible inside the container through `lsusb`. In our case, the Google Pixel 7 was visible inside the container, but ADB couldn't detect it.

Instead of having ADB inside Docker communicate directly with the USB device, we configured the container to use the **ADB server running on the Linux host**. The host already had working USB access to the device, so this avoided the USB passthrough issue.

### 🛠️ 1. Start the ADB Server on the Host

Connect your Android device, enable **Developer options** and **USB debugging**, unlock the device, and authorize the computer when prompted.

On the Linux host, run:

```
adb devices -l
```

Verify that the device appears in the list.

Start the ADB server in a dedicated terminal:

```
adb -a nodaemon server start
```

- `-a` allows the ADB server to listen on all network interfaces.
- `nodaemon` keeps the server running in the foreground.

⚠️ **Security warning:** ADB server access is highly privileged and can allow control of connected devices. Listening on all interfaces may expose the server to other machines on your network. Use this configuration only on a trusted network, and stop the server when you're finished. Prefer a loopback-only or otherwise restricted configuration when practical.

### 🐳 2. Launch the Docker Container

Start the container with host networking and the existing `usbmuxd` socket mount:

```
docker run -it --rm \
  --network host \
  -v /var/run/usbmuxd:/var/run/usbmuxd \
  -e ADB_SERVER_SOCKET=tcp:127.0.0.1:5037 \
  libimobiledevice-docker fish
```

**What these options do:**

| Option | Purpose |
| --- | --- |
| `--network host` | Allows the container to reach services on the Linux host's network namespace. |
| `-v /var/run/usbmuxd:/var/run/usbmuxd` | Preserves access to the host's `usbmuxd` socket for iOS communication. |
| `ADB_SERVER_SOCKET=tcp:127.0.0.1:5037` | Directs ADB commands inside the container to the host's ADB server on port 5037. |
| `libimobiledevice-docker fish` | Starts the forensics image with an interactive Fish shell. |

Because host networking is enabled, `127.0.0.1` inside the container refers to the host's loopback interface on Linux.

### ✅ 3. Verify Android Tool Access

Inside the container, run:

```
adb devices -l
androidqf --help
mvt-android --help
```

The `adb devices -l` command should list the Android device connected to the host. AndroidQF and MVT can then be invoked from the same environment.

### 🔍 Troubleshooting

If the Android device doesn't appear:

1. Confirm that the host detects it with `adb devices -l`.
2. Ensure the host ADB server is still running.
3. Verify that the container was started with `--network host`.
4. Check that `ADB_SERVER_SOCKET` points to `tcp:127.0.0.1:5037`.
5. Unlock the phone and accept any USB debugging authorization prompt.

### 🧹 4. Stop the ADB Server

When you're finished, stop the host ADB server with:

```
adb kill-server
```

Run this on the host, not inside the container. It stops the shared ADB server, so other host applications using that server will also lose their connection until it is restarted.

### 📱 Summary

This setup combines iOS and Android tooling in one Docker environment:

- 🍎 **iOS:** `libimobiledevice`, `pymobiledevice3`, and `usbmuxd`.
- 🤖 **Android:** ADB, AndroidQF, and MVT.
- 🐳 **Docker:** A consistent, isolated tool environment.
- 🔗 **Host ADB server:** Provides Android device access without relying on direct USB communication from inside the container.

The key lesson is that a USB device being visible inside Docker does not necessarily mean ADB can communicate with it. Reusing the host's working ADB server provides a practical workaround while preserving the existing iOS workflow.

One recommendation: before publishing, consider replacing the `adb -a` command with a loopback-only configuration if your ADB version and setup support it. The all-interface listener is convenient, but it unnecessarily increases exposure on a networked machine.
