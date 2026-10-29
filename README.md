# dev-toolkit

Small tools that take the busywork out of my day. Each tool lives in its own folder under `tools/` with
its own README and install script.

| Tool | What it does |
|---|---|
| [tlog](tools/tlog) | Azure DevOps sprint helper: plan sprint tasks, log daily hours, daily reminder, per-story summary for timesheets. Includes Claude Code skills. |

## Install

```bash
git clone https://github.com/mhmdnsr-dev/dev-toolkit.git
cd dev-toolkit
./install.sh            # install every tool
./install.sh tlog       # or just one
./uninstall.sh [tool]   # remove links (configs are kept)
```

Tools are installed as symlinks, so a `git pull` updates them in place.

## Adding a tool

Create `tools/<name>/` with:

- `README.md`: what it does and how to use it
- `install.sh` / `uninstall.sh`: idempotent; link things into place, never copy secrets into the repo
- `config.example.env` if it needs settings: real values go in `~/.config/<name>/`, which isn't committed

Then add a row to the table above.
