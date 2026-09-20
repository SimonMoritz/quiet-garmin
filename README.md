# Quiet 970

A restrained, AMOLED-first watch face for the Garmin Forerunner 970. It uses a
large 24-hour clock, compact date, and a quiet row for heart rate, battery, and
steps. The always-on state removes live details, dims the face, and shifts it
slightly to reduce burn-in risk.

## Design

- Black background and system fonts for low overhead and crisp rendering.
- White primary type, neutral-gray secondary type, and one warm amber accent.
- Resolution-independent placement, currently scoped to the Forerunner 970.
- No network access, storage, or personal-data permissions.

## Build on Ubuntu

The project uses Garmin's Monkey C compiler, Java, and OpenSSL. It does not
need Python or Node dependencies.

1. Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
   and select an active SDK. The current local setup uses SDK **9.2.0** and
   OpenJDK **21**.
2. In SDK Manager, sign in to Garmin and download **Forerunner 970** from the
   **Devices** tab. Its compiler target is `fr970`.
3. Install Garmin's **Monkey C** extension in VS Code (recommended by this
   workspace).
4. Generate a signing key once, if `developer_key.der` does not already exist:

   ```bash
   (umask 077; openssl genrsa 4096 | openssl pkcs8 -topk8 -inform PEM \
     -outform DER -out developer_key.der -nocrypt)
   ```

   Keep this key backed up privately; reuse it for later versions. Keys are
   ignored by Git. A key has already been generated in the current workspace.
5. Build from the project directory:

   ```bash
   ./scripts/build.sh
   ```

   This reads `~/.Garmin/ConnectIQ/current-sdk.cfg` and writes
   `bin/Quiet970.prg`. Override `CIQ_SDK_HOME` or `DEVELOPER_KEY` when needed.
   Additional compiler arguments are forwarded, e.g. `./scripts/build.sh -r`
   for a release build. VS Code's default build task runs the same script.

For the extension's own build/debug commands, set **Monkey C: Developer Key
Path** to the absolute path of your key. The current workspace has this in
an ignored `.vscode/settings.json`.

### Ubuntu 24.04 GUI compatibility

Garmin's native SDK Manager and simulator require WebKitGTK 4.0, which is not
shipped in Ubuntu 24.04. The current machine uses the community-maintained
[AppImage packages](https://github.com/pcolby/connectiq-sdk-manager) for those
two GUI applications, alongside the official SDK/compiler. Their required
`libwebkit2gtk-4.1-0` and `libfuse2t64` system packages are already installed.
No system packages were added for this project.

If SDK Manager's embedded sign-in window is blank, use the installed
[community CLI manager](https://github.com/lindell/connect-iq-sdk-manager-cli)
instead. It authenticates through Garmin in your regular browser:

```bash
connect-iq-sdk-manager login
# Open the localhost URL it prints and sign in to Garmin.
connect-iq-sdk-manager device download --device fr970 --include-fonts
```

If Garmin returns HTTP 429 / Cloudflare error 1015, wait for the indicated
`Retry-After` interval before retrying. Repeated refreshes may extend the block.
Device downloads require a successful login; installing the SDK alone does
not install the `fr970` compiler target.

Local tools are installed under `~/.Garmin/ConnectIQ/`; launchers in
`~/.local/bin/` provide `monkeyc`, `monkeydo`, `connectiq`, and
`garmin-sdk-manager`. The compiler launchers follow the active SDK setting;
the simulator AppImage is pinned to 9.2.0 and should be updated alongside
future SDK upgrades.

### Run in the simulator

Start `connectiq` in one terminal. After its window opens, run in another:

```bash
./scripts/build.sh
monkeydo bin/Quiet970.prg fr970
```

Check normal and always-on display modes, missing heart-rate/step data, and
long values before installing on the watch. `preview.png` is a design reference,
not a verified screenshot of the compiled face.

## Install on your watch

Build `bin/Quiet970.prg`, connect the watch over USB, and copy the PRG into the
watch's `GARMIN/APPS` directory. Eject cleanly, then select **Quiet 970** under
the watch-face menu.

## Store handoff

Before publishing, test normal and always-on modes on physical hardware and
check memory/battery use in the simulator. Export a signed IQ package from the
Monkey C extension, then upload it in the Connect IQ developer portal with
screenshots, description, pricing, and support details.

## Next design pass

The visual values are deliberately centralized near the top of `onUpdate`.
After seeing it on the actual display, adjust the three colors and the vertical
ratios (`0.32`, `0.53`, `0.72`) before adding settings or more devices.
