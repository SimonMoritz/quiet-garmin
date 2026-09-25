# Garmin Connect IQ projects

This repository holds independent Garmin watch faces, widgets, and watch apps. Each installable project has its own manifest, application ID, code, resources, and device list. Reusable Monkey C code lives in optional modules under `shared/`.

The first project is [Quiet 970](projects/quiet970/README.md), a watch face for the Forerunner 970.

## Quick start

Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/), download a device target in SDK Manager, and create a private `developer_key.der` as described in [development setup](docs/development.md). Then run:

```bash
./scripts/build.sh --list
./scripts/build.sh quiet970
```

For simulator testing, start `connectiq`, then run `monkeydo bin/quiet970/fr970.prg fr970` in another terminal.

The build command accepts a project and optional device ID. A project's `default-device.txt` supplies the device when omitted. Compiler flags follow the device, for example `./scripts/build.sh quiet970 fr970 -r`. Builds go to `bin/<project>/<device>.prg`.

See [architecture and adding projects](docs/architecture.md) for watch faces, widgets, and watch apps, [development setup](docs/development.md) for SDK and simulator use, and [AGENTS.md](AGENTS.md) for a quick repository map for coding agents.

Source is available for educational purposes only. See [LICENSE](LICENSE).
