# Quiet 970

A restrained AMOLED watch face for the Garmin Forerunner 970. It uses a large 24-hour clock, a compact date, and three configurable metrics. The always-on state hides live details, dims the face, and shifts it slightly to reduce burn-in risk.

The left, center, and right slots can show heart rate, battery, steps, or stress. Defaults are heart rate, battery, and stress. Stress uses blue (0–25), green (26–50), yellow (51–75), and red (76–100). Missing readings display `--`. Change slots in Garmin Connect or Garmin Express and sync the watch; the face refreshes settings in `onSettingsChanged()`.

The design uses system fonts, a black background, white primary type, gray secondary type, and an amber accent. Layout ratios and colors are near the top of `source/Braun970View.mc`. The [preview image](preview.png) is a design reference, not a verified capture.

## Build

From the repository root:

```bash
./scripts/build.sh quiet970
monkeydo bin/quiet970/fr970.prg fr970
```

See the repository [development guide](../../docs/development.md) for SDK setup, signing, simulator use, and installation. The existing application ID is retained in this project's manifest.

## Verified baseline

On 2026-09-20, SDK 9.2.0 built the `fr970` target without compiler warnings. The face ran in the Forerunner 970 simulator, including missing heart-rate, battery, and zero-step states. See the [simulator screenshot](docs/simulator-fr970.png) and [configurable stress screenshot](docs/simulator-configurable-stress.png).

A 24-hour accelerated always-on test completed without a burn-in shutdown. Low-power rendering measured roughly 2% luminance, below Garmin's 10% limit; the [heatmap](docs/always-on-heatmap.png) confirms the detail row is hidden. Physical-watch battery testing and final visual tuning remain before release.
