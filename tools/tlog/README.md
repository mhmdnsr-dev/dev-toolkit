# tlog

A small CLI for the Azure DevOps sprint routine: plan your sprint tasks, log daily hours, get reminded
when you haven't logged enough, and summarize hours per story for timesheets. It also includes two
[Claude Code](https://claude.com/claude-code) skills that drive it with plain language.

It wraps the `az boards` CLI and applies your team's conventions (area path, Activity, idle tasks,
Completed/Remaining Work), so you don't have to fill the same fields by hand every day.

## Requirements

- Python 3.9+
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with the `azure-devops` extension,
  logged in (`az login` or `az devops login`)
- Linux with systemd and `notify-send` for the reminder (everything else works anywhere)

## Install

```bash
./install.sh     # links tlog into ~/.local/bin, the skills into ~/.claude/skills,
                 # and creates ~/.config/tlog/config.env from config.example.env if missing
./uninstall.sh   # stops the reminder and removes those links (your config is kept)
```

Then edit `~/.config/tlog/config.env` (see [config.example.env](config.example.env)). Every setting can
also be overridden with an environment variable of the same name.

## Usage

```bash
tlog                                   # my tasks in the current sprint: est / done / remaining
tlog cer 4                             # log 4h on the Ceremonies (Meetings) task
tlog "login page" 3 "Form validation"  # match a task by title words (or task id / parent story id)
tlog idle 2.5 "Helped a teammate"      # log on today's "<TLOG_NAME> - 29 Oct 2026" idle task (created if missing)
tlog idle -1                           # undo a wrong log (negative hours)
tlog day                               # what I logged today vs the daily target
tlog day 2026-10-30                    # ...or another day (current sprint tasks only)
tlog stories [--json]                  # stories in the sprint with everyone's tasks
tlog sprint                            # current sprint name and dates

tlog summary                           # my hours per story (est / done / remaining), for timesheets
tlog summary --days                    # ...plus a day-by-day breakdown with comments
tlog summary --csv > sprint.csv        # date,story,task,hours,comment rows (Excel/Sheets)
tlog summary --sprint prev             # previous sprint (or part of a name: --sprint "Sprint 1")

tlog create --from plan.json --dry-run # preview a plan, then run without --dry-run to create
tlog create --parent 1002 --title "Login page (Frontend implementation)" --hours 8

tlog remind start                      # daily reminder at 16:00 on TLOG_WORKDAYS if today < TLOG_DAILY
tlog remind start 17:30 --days Mon..Fri
tlog remind status | test | stop
```

A plan file is a list of tasks (`type` defaults to Task, `activity` to `TLOG_DEV_ACTIVITY`):

```json
[
  {"parent": 1001, "type": "Meetings", "title": "Ceremonies (Planning 4h – Review 2h – Retrospective 1.5h)", "hours": 7.5},
  {"parent": 1002, "title": "Login page (Frontend implementation)", "hours": 16}
]
```

## How it works

| What | Behaviour |
|---|---|
| Sprint | the team's current iteration, found automatically |
| New tasks | iteration = current sprint, area = `TLOG_AREA`, assigned to `TLOG_USER`, Original Estimate = Remaining Work = hours |
| Logging | Completed Work += hours, Remaining Work -= hours (never below 0); comment goes to Discussion |
| Idle time | one task per day, `<TLOG_NAME> - DD Mon YYYY`, Activity `TLOG_IDLE_ACTIVITY`, under the sprint story whose title contains `TLOG_IDLE_STORY`; Estimate = Completed = hours logged that day; optional extra field via `TLOG_IDLE_REASON_FIELD` |
| "Logged today" | sum of today's Completed Work changes in your tasks' history, so logs from the Azure DevOps web UI count too; hours count on the day they are saved |
| Reminder | a systemd user timer (`~/.config/systemd/user/tlog-remind.{service,timer}`) runs `tlog remind check` and shows a desktop notification only if today is under target. Installing doesn't start it; once started it runs until `tlog remind stop` |

## Claude Code skills

- `/sprint-plan [hours]`: reads the sprint's stories, proposes tasks for your role up to the total,
  waits for your review, then creates them. Put your personal rules (role, default total, title
  patterns, ceremonies item, stories to skip) in `~/.config/tlog/planning.md`.
- `/log-hours 4 ceremonies, 2.5 idle: <comment>`: logs the entries and shows the day's total.
