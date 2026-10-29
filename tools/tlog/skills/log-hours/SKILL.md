---
name: log-hours
description: Log my daily hours on Azure DevOps sprint tasks with the tlog CLI. Use when the user says things like "log 4 ceremonies + 2.5 idle", "log today", "log my hours", or asks what they logged today or per story.
argument-hint: "<hours task [comment]>, ... e.g. 4 ceremonies, 2.5 idle: helped with X"
---

# Log hours

Log hours with the `tlog` CLI (on PATH as `tlog`; settings in `~/.config/tlog/config.env`).

## Steps

1. Run `tlog` to see the user's tasks in the current sprint (id, est, done, remaining).

2. Parse the request into entries of (task, hours, comment):
   - "ceremonies"/"meetings" → `cer`, "idle" → `idle`, otherwise the task id or title keywords.
     `idle` always logs on today's `<TLOG_NAME> - DD Mon YYYY` idle task and creates it if needed.
   - Support work (helping teammates, creating docs/artifacts, support meetings) → `tlog support <hours> "<what>"`,
     which logs on a `Support to <what>` task under the sprint's scrum/operations story (created if needed).
     Prefer this over idle when the user says what the support was for. Reuse the exact same `<what>`
     to add hours to an existing support task (check `tlog` for its title).
   - A comment is added only when the user gives one. Use the user's wording; drop anything they say
     not to include (e.g. links they asked you not to reference) and keep only the text.
   - The daily target is `TLOG_DAILY` (shown by `tlog day`). If the entries don't add up to it, tell the
     user before logging.

3. Log each entry:
   `tlog <task> <hours> "<comment>"` (omit the comment when there is none).
   If a keyword matches several tasks, tlog lists them: pick the one that clearly fits, or ask.
   To undo a wrong entry, log negative hours: `tlog <task> -<hours>`.

4. Run `tlog day` and show the user the day's summary.

## Related

- Timesheet / "how many hours on each story": `tlog summary` (add `--days` for a per-day breakdown,
  `--csv` for a file, `--sprint prev` for the previous sprint).
- Daily reminder: `tlog remind start [HH:MM] [--days ...]`, `tlog remind stop`, `tlog remind status`.
  Only start or stop it when the user asks.
