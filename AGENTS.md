# Repository guide for coding agents

This is a multi-project Garmin Connect IQ repository. Start with [README.md](README.md), then use [docs/architecture.md](docs/architecture.md) for project conventions and [docs/development.md](docs/development.md) for SDK setup. Each product has its own README under `projects/<name>/`.

## Where things live

- `projects/<name>/manifest.xml` defines that installable product's app ID, type, entry point, permissions, and supported devices.
- `projects/<name>/monkey.jungle`, `source/`, and `resources/` contain its build paths, Monkey C code, and assets. Keep product-specific code and settings here.
- `shared/<module>/source/` contains reusable Monkey C code. A project opts into a module by adding its path to `base.sourcePath` in its Jungle file.
- `scripts/build.sh` is the repository build entry point. `.build/` contains ignored compiler intermediates; `bin/` contains the runnable PRG and simulator metadata. Edit `.mc` files under `projects/`, never generated `.mir` files.
- `projects/quiet970/` is the existing Forerunner 970 watch face. Preserve its manifest ID when changing it; use a new ID for every new product.

## Working in this repository

1. Identify the target project and read its README and manifest before editing. Check its supported devices and app type rather than assuming Quiet 970's choices apply elsewhere.
2. Build from the repository root with `./scripts/build.sh <project> [device]`. Run `./scripts/build.sh --list` to see projects. Compiler flags can follow the device. Output is `bin/<project>/<device>.prg`.
3. For code or resource changes, compile the affected project for at least its default device. Run `git diff --check` for all changes. If a project supports more devices, check the affected device variants too.
4. Keep signing keys and generated PRG/IQ files out of Git. The default key is `developer_key.der`; see `docs/development.md` for overrides and setup.
5. Update the relevant project README and repository guides when paths, build commands, devices, or project conventions change.

The repository's VS Code task builds a selected project. For Garmin extension commands that require a single project root, open `projects/<name>/` as the workspace.
