# Repository architecture

Each directory under `projects/` is one independently installable Connect IQ application. The build script treats every project the same; the project's manifest determines whether it is a watch face, widget, or watch app.

```text
projects/
  quiet970/
    manifest.xml           application ID, type, entry point, permissions, devices
    monkey.jungle          source and resource paths
    default-device.txt     optional local build default
    source/                project-specific Monkey C
    resources/             project-specific strings, settings, icons, layouts
    docs/                  project-specific screenshots
shared/
  watch_numbers/source/    optional reusable number formatting module
scripts/build.sh           selects project and device
bin/<project>/<device>.prg  ignored build output
```

Project boundaries matter: use a distinct manifest ID for every installable product, and keep its settings, assets, permissions, and supported devices in that project's directory. Do not copy Quiet 970's manifest ID into a new project. Existing Quiet 970 builds retain their original ID, so an update remains associated with the same watch face.

## Add a project

1. Create `projects/<name>/` with `manifest.xml`, `monkey.jungle`, `source/`, and `resources/`. Use a lowercase directory name beginning with a letter; digits, underscores, and hyphens are allowed. Garmin's VS Code **Monkey C: New Project** command can generate the initial type-specific app, entry point, and resources. Move those files into the new directory.
2. Set the manifest's `type` to `watchface`, `widget`, or `watch-app` as appropriate. Give the project its own application ID and entry class. Add each supported product under `iq:products`; choose permissions and `minApiLevel` for the APIs the project actually uses. Device support and available app types vary, so check Garmin's device reference before adding a product.
3. Use this basic Jungle file in the project directory:

   ```text
   project.manifest = manifest.xml
   base.sourcePath = source
   base.resourcePath = resources
   ```

   To include a shared module, append its source directory, for example `base.sourcePath = source;../../shared/watch_numbers/source`. Add only the modules the project needs. Garmin's Jungle qualifiers can also add device or screen-specific source and resource paths.
4. Put one device ID, such as `fr970`, in `default-device.txt` if a no-device build should be available. Install that target in SDK Manager. Build with `./scripts/build.sh <name> [device]`; the PRG appears in `bin/<name>/<device>.prg`.

Watch faces normally return a `WatchUi.WatchFace` from the entry app. Widgets and watch apps use their own `WatchUi.View` based entry and lifecycle. Keep these type-specific classes inside the project; put broadly useful formatting or data helpers in a module under `shared/`. Quiet 970 currently opts into `WatchNumbers.compact()` as an example.

## Build contract

`scripts/build.sh` validates the project name and required files, selects the requested or default device, resolves the active SDK and private signing key, then invokes `monkeyc` from the selected project directory. This keeps relative Jungle paths local to the project. `CIQ_SDK_HOME`, `CIQ_HOME`, `CIQ_DEVICES_HOME`, and `DEVELOPER_KEY` can override local defaults. Arguments after the device go directly to `monkeyc`. The no-argument command still builds Quiet 970 for compatibility with the original workflow.

The script creates a single-device PRG for simulator testing or USB sideloading. For store publication, export and test an IQ package containing every supported device using Garmin's tooling.

The repository's VS Code build task prompts for a project and uses that project's default device. Garmin extension commands that expect a single project root should be run with `projects/<name>/` opened as the VS Code workspace; configure the developer key path there if the extension needs it.

## Official references

- [Manifest and Permissions](https://developer.garmin.com/connect-iq/core-topics/manifest-and-permissions/) — application identity, type, products, and permissions.
- [Build Configuration](https://developer.garmin.com/connect-iq/core-topics/build-configuration/) and [Jungle Reference](https://developer.garmin.com/connect-iq/reference-guides/jungle-reference/) — source paths, resource paths, and device-specific variants.
- [Resources](https://developer.garmin.com/connect-iq/core-topics/resources/) — strings, icons, layouts, and resource qualifiers.
- [Device Reference](https://developer.garmin.com/connect-iq/device-reference/) — target IDs, supported app types, screen sizes, and memory limits.
- [Visual Studio Code Extension](https://developer.garmin.com/connect-iq/reference-guides/visual-studio-code-extension/) — project generation, debugging, and IQ export.
- [Monkey C Command Line Setup](https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/) — SDK and compiler setup.
