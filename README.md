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

1. Install Garmin Connect IQ SDK Manager and a current Connect IQ SDK.
2. Install the **Monkey C** extension in VS Code.
3. Open this folder and use **Monkey C: Build for Device**, selecting
   `fr970`, or run:

   ```bash
   monkeyc -f monkey.jungle -d fr970 -o bin/Quiet970.prg -y /path/to/developer_key
   ```

4. Start Garmin's simulator, choose the Forerunner 970, and run the project.

To make a developer key once:

```bash
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
  -in developer_key.pem -out developer_key -nocrypt
```

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
