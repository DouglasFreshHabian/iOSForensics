# 📱 Jailbreaking an iPhone 13 Pro Max with Ubuntu, TrollStore, Dopamine & OpenSSH

A practical walkthrough for reproducing my iPhone jailbreak setup from
an Ubuntu Linux workstation, then connecting to the phone over SSH. This
is also the foundation for experimenting with advanced iOS research and
device automation.

> ⚠️ **Use this guide only on a device you own or are explicitly
> authorized to administer.** Jailbreaking reduces some of iOS's
> built-in security protections. Keep SSH on a trusted local network,
> protect your credentials, and understand that software updates may
> remove your jailbreak options.

## 🧰 Test setup

-   **Computer:** Ubuntu Linux
-   **Phone:** iPhone 13 Pro Max (`iPhone14,3`)
-   **iOS:** 16.3.1
-   **TrollStore installer:** TrollInstallerX
-   **Jailbreak:** Dopamine
-   **Package manager:** Sileo
-   **Remote access:** OpenSSH

The steps below reflect the workflow used in this walkthrough. Installer
interfaces and supported versions can change, so check the official
project documentation before repeating the process on another device.

## 🗺️ Overview

1.  Keep the iPhone on iOS 16.3.1 while checking jailbreak
    compatibility.
2.  Install TrollInstallerX on the iPhone from Ubuntu using the Impactor
    application.
3.  Run TrollInstallerX on the phone to install TrollStore.
4.  Install Dopamine through TrollStore.
5.  Open Dopamine and activate the jailbreak.
6.  Use Sileo to install the OpenSSH metapackage.
7.  Find the iPhone's local IP address and connect from Ubuntu using
    SSH.

## 1. 🔎 Confirm the device and iOS version

On the iPhone, open:

**Settings → General → About**

Check the iOS version before proceeding. This walkthrough used **iOS
16.3.1** on an iPhone 13 Pro Max.

🛑 **Don't update first if you're preserving a jailbreak opportunity.**
Jailbreak compatibility depends on the exact device and iOS build, and
downgrading may not be possible later. Back up important data before
making system changes.

## 2. 🖥️ Install TrollInstallerX from Ubuntu

1.  Download the Impactor application and the TrollInstallerX `.ipa`
    from their trusted project sources.
2.  Connect the iPhone to the Ubuntu computer with USB.
3.  Unlock the iPhone and approve the **Trust This Computer** prompt if
    it appears.
4.  Launch Impactor on Ubuntu.
5.  Sign in through Impactor as required by its interface.
6.  Drag the TrollInstallerX `.ipa` file into the Impactor window and
    start the installation.
7.  Wait for installation to finish.

🔐 **Credential safety:** Never display an Apple Account password,
verification code, recovery key, or other private credential during a
livestream. Consider using a dedicated account for sideloading where
appropriate, and only use tools and downloads you trust.

## 3. 📲 Install TrollStore on the iPhone

1.  On the iPhone, open the newly installed **TrollInstallerX** app.
2.  Tap **Install TrollStore**.
3.  Follow the on-device prompts.
4.  If the installer asks you to choose an app for the persistence
    helper, select an appropriate app as directed by the installer.
5.  Wait for the process to finish and verify that **TrollStore**
    appears on the Home Screen.

TrollStore is an app installer; **TrollStore by itself is not a
jailbreak**. It provides the installation route used here for Dopamine.

## 4. 🧪 Install Dopamine using TrollStore

1.  Obtain the Dopamine `.ipa` from the official Dopamine project.
2.  Open TrollStore on the iPhone.
3.  Install the Dopamine `.ipa` using TrollStore.
4.  Wait for installation to complete.
5.  Open Dopamine and follow its prompts to activate the jailbreak.
6.  Confirm that Dopamine reports the device as jailbroken and that its
    package manager (Sileo) opens.

Dopamine is a **rootless, semi-untethered jailbreak**. After a full
reboot, you may need to open Dopamine and activate the jailbreak again.
Follow the current Dopamine documentation for your exact version.

## 5. 📦 Install OpenSSH through Sileo

1.  Open **Sileo** on the jailbroken iPhone.
2.  Refresh package sources if prompted.
3.  Search for the **OpenSSH** metapackage.
4.  Review the package details and install it.
5.  Allow Sileo to complete the installation.

OpenSSH provides SSH server functionality so the computer can connect to
the phone. Installing it does not, by itself, prove that the service is
running or reachable; the next steps test that.

## 6. 📡 Find the iPhone's IP address

On the iPhone, open:

**Settings → Wi-Fi → tap ⓘ beside the connected network → IP Address**

Write down the local IP address. In the examples below, replace
`192.168.1.122` with the iPhone's actual address.

For the first connection, keep the iPhone and Ubuntu computer on the
same trusted Wi-Fi network. Guest networks or client isolation can
prevent devices from reaching each other.

## 7. 🐧 Test SSH from Ubuntu

Open a terminal on Ubuntu and test whether port 22 is reachable:

``` bash
nc -vz 192.168.1.122 22
```

Replace the example address with the iPhone's IP address.

If the port is reachable, try connecting as the mobile user:

``` bash
ssh mobile@192.168.1.122
```

If that account is unavailable or the connection requires another
account, try:

``` bash
ssh root@192.168.1.122
```

Use the password configured for that account. The first connection may
ask you to verify the SSH host key; confirm that you are connecting to
your own phone before accepting it.

### 🛠️ If SSH doesn't connect

-   **Connection timed out:** Confirm both devices are on the same
    trusted network and check for Wi-Fi client isolation.
-   **Connection refused:** OpenSSH may not be running or listening on
    port 22. Recheck the package installation and device state.
-   **Local Network Sharing:** If you are using a VPN such as Mullvad,
    make sure to allow access to other devices on the local network.

## 8. 🔐 Change default passwords

Do not leave a known or default jailbreak password in place. Once
connected, change the password for each account you use, following the
environment's account configuration.

For the current account:

``` bash
passwd
```

If you administer both `root` and `mobile`, change each account's
password separately as appropriate. Use a unique password and never show
it on stream.

## 9. 🧪 Verify the remote shell

Once SSH succeeds, run a few read-only commands:

``` bash
id
uname -a
whoami
```

These confirm which account is connected and provide basic information
about the shell environment.

You can also test file transfer from Ubuntu after SSH works. For
example, to copy a file **from Ubuntu to the iPhone**, use `scp` with a
destination path writable by the selected account. Check paths and
permissions first; Dopamine is rootless, so it does not make the entire
iOS filesystem freely writable.

## 🎥 Suggested live-demo sequence

1.  Show the iPhone model and iOS version in **Settings → General →
    About**.
2.  Explain why you preserved iOS 16.3.1 rather than updating.
3.  Show Impactor and the TrollInstallerX installation workflow (without
    exposing account credentials).
4.  Demonstrate TrollInstallerX installing TrollStore.
5.  Show TrollStore installing Dopamine.
6.  Open Dopamine and show the active jailbreak state.
7.  Open Sileo and show the OpenSSH metapackage.
8.  Find the phone's IP address.
9.  From Ubuntu, run the port check and SSH into the phone.
10. Run `id`, `uname -a`, and `whoami` to verify the session.
11. Explain what SSH enables next---and what it does **not**
    automatically provide, such as native touchscreen tap injection.

🎬 **Livestream safety checklist** - Hide passwords, verification codes,
email addresses, and account details. - Avoid exposing the phone's
public IP address or unrelated personal notifications. - Keep SSH
restricted to a trusted local network; do not forward port 22 from your
router to the internet. - Back up important data before modifying the
device. - Explain that jailbreak tweaks and packages can introduce
instability or security risks.

## 🧭 What to explore next

With the jailbreak active and SSH available, potential next steps
include inspecting the accessible filesystem, transferring research
artifacts, exploring processes and launch services, and investigating
jailbreak-compatible instrumentation. Native touchscreen automation is a
separate capability and will require a supported tool, service, or
tweak; SSH alone does not inject taps or swipes.

## 🔗 Official project references

-   [Dopamine --- official project](https://github.com/opa334/Dopamine)
-   [Dopamine installation
    guide](https://ios.cfw.guide/installing-dopamine-trollstore/)
-   [TrollInstallerX --- official
    project](https://github.com/alfiecg24/TrollInstallerX)
-   [TrollInstallerX installation
    guide](https://ios.cfw.guide/installing-trollstore-trollinstallerx/)
-   [TrollStore --- official
    project](https://github.com/opa334/TrollStore)

------------------------------------------------------------------------

📌 **Disclosure:** This README describes a personal walkthrough on a
device I own. Exact steps, interfaces, and compatibility can change with
tool versions. Verify current documentation and use these techniques
responsibly.
