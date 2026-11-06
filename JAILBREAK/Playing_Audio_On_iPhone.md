# 🔊 Playing Audio on a Jailbroken iPhone via SSH

Successfully playing audio directly through an iPhone's speakers using SSH on a rootless jailbroken iPhone running iOS 16.3.1.

## 📱 Device Information

- Device: iPhone 13 Pro Max
- iOS: 16.3.1
- Architecture: ARM64
- Jailbreak: Rootless
- Package Manager: Procursus / APT

## 🛠️ Requirements

Install `mpg123` on the iPhone:

```bash
apt update
apt install mpg123
````

Verify installation:

bash

```bash
mpg123 --version
```

Verify CoreAudio support:

bash

```bash
mpg123 --list-modules
```

Expected output includes:

text

```text
coreaudio      output  Output audio using Mac OS X's CoreAudio.
```

## 🎵 Step 1: Generate an MP3 Audio File

On your computer, use FFmpeg to generate a 440 Hz sine wave lasting 3 seconds.

bash

```bash
ffmpeg -f lavfi -i "sine=frequency=440:duration=3" \
       -codec:a libmp3lame -b:a 192k test.mp3
```

This generates a simple test tone.

## 📤 Step 2: Transfer Audio to the iPhone

Transfer the MP3 over SSH using SCP:

bash

```bash
scp test.mp3 root@192.168.2.12:/var/mobile/test.mp3
```

Replace the IP address with your iPhone's actual IP address.

## 🔐 Step 3: SSH Into the iPhone

bash

```bash
ssh root@192.168.2.12
```

## 🔊 Step 4: Play Audio Through CoreAudio

Execute:

bash

```bash
mpg123 -o coreaudio -r 44100 /var/mobile/test.mp3
```

### Command breakdown

| Argument | Description |
| --- | --- |
| `mpg123` | MP3 audio player |
| `-o coreaudio` | Uses Apple's CoreAudio output |
| `-r 44100` | Sets the audio output sample rate to 44.1 kHz |
| `/var/mobile/test.mp3` | Audio file to play |

🎉 **Success\!** Audio plays directly through the iPhone's audio output without requiring `afplay`, `say`, or a third-party iOS music player.

## 📝 Notes

- `mpg123` must be installed on the iPhone.
- The `coreaudio` output module must be available.
- Generate actual MP3 files rather than relying on CAF files.
- The iPhone must have an accessible audio output route.
- SSH provides remote command-line access to trigger playback.

## 🚀 Result

An iPhone can be used as a remotely controlled audio playback device through SSH using FFmpeg, SCP, and mpg123.

---
