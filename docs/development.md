# Development setup

The repository uses Garmin's Monkey C compiler, Java, and OpenSSL. It has no Python or Node dependencies.

1. Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) and select an active SDK in SDK Manager. The last locally verified setup used SDK 9.2.0 and OpenJDK 21.
2. Download each target device from SDK Manager's **Devices** tab. Quiet 970 uses Forerunner 970, whose compiler ID is `fr970`. SDK installation alone does not install device targets.
3. Create a signing key in the repository root if you do not already have one:

   ```bash
   (umask 077; openssl genrsa 4096 | openssl pkcs8 -topk8 -inform PEM \
     -outform DER -out developer_key.der -nocrypt)
   ```

   Keep this key private and backed up; reuse it for updates. The key and build outputs are ignored by Git. Set `DEVELOPER_KEY` to use a key elsewhere.

## Build and simulate

```bash
./scripts/build.sh --list
./scripts/build.sh quiet970 fr970
```

Start `connectiq` in one terminal. After its window opens, run `monkeydo bin/quiet970/fr970.prg fr970` in another. Use a project's own target ID and output path for other builds. Check missing data, long values, device-specific layouts, and any always-on behavior before installing on a watch.

To sideload, copy the PRG into the watch's `GARMIN/APPS` directory over USB, eject it cleanly, and select the installed app on the watch. To publish, use Garmin's export tooling to make a signed IQ package for all supported products, and test on hardware. The build script creates development PRGs only.

## Local Linux notes

On Ubuntu 24.04, Garmin's native SDK Manager and simulator can require WebKitGTK 4.0, which is not shipped with that release. This workspace previously used community-maintained [SDK Manager and simulator AppImages](https://github.com/pcolby/connectiq-sdk-manager) with the official compiler. A [CLI SDK manager](https://github.com/lindell/connect-iq-sdk-manager-cli) can be used when the embedded sign-in is blank:

```bash
connect-iq-sdk-manager login
connect-iq-sdk-manager device download --device fr970 --include-fonts
```

A Garmin HTTP 429 or Cloudflare 1015 response requires waiting for the indicated retry interval. The original local launchers live under `~/.local/bin/`; the active SDK selection lives at `~/.Garmin/ConnectIQ/current-sdk.cfg`. These paths can differ on another machine. The build script supports `CIQ_SDK_HOME`, `CIQ_HOME`, and `CIQ_DEVICES_HOME` overrides.
