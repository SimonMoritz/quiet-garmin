# Quiet 970

A restrained AMOLED watch face for the Garmin Forerunner 970. It uses a large 24-hour clock, a compact date, and three configurable metrics. The same layout is drawn in normal and low-power updates, so the metrics remain visible. Garmin still controls the display brightness and update rate in low-power mode.

The left, center, and right slots can show heart rate, battery, steps, or stress. Defaults are heart rate, battery, and stress. Values use a light neutral color, labels use a darker gray, and heart rate remains the sole amber accent. Stress is a neutral number regardless of range. Missing readings display `--`. Change slots in Garmin Connect or Garmin Express and sync the watch; the face refreshes settings in `onSettingsChanged()`.

The time has two drawn dots placed symmetrically around the numeral center, independent of the font's punctuation glyph. The design uses system fonts, a black background, and restrained color. Layout ratios and colors are near the top of `source/Braun970View.mc`. The [preview image](preview.png) is an early design reference; see the current simulator capture below.

## Build

From the repository root:

```bash
./scripts/build.sh quiet970
monkeydo bin/quiet970/fr970.prg fr970
```

See the repository [development guide](../../docs/development.md) for SDK setup, signing, simulator use, and installation. The existing application ID is retained in this project's manifest.

## Simulator check

On 2026-09-25, SDK 9.2.0 built the `fr970` target without compiler warnings. The [current simulator capture](docs/simulator-fr970-current.png) shows the centered colon, neutral stress, and label/value contrast. The full layout remained visible with the simulator's Sleep Mode and Always-On mode enabled.

An accelerated 24-hour Always-On test completed without a burn-in shutdown. The [final heat-map reading](docs/always-on-current-heatmap.png) was 4.96% luminance, below Garmin's 10% limit. The old dimmed and colorized captures are preserved in `docs/archive/`. Physical-watch battery testing and final visual tuning remain before release.
